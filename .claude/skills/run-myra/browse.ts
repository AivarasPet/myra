// Headless browser driver for the Myra web app. Reads one command per line from stdin.
// Run from the repo root: bun .claude/skills/run-myra/browse.ts < script.txt
//
// Talks to the installed Microsoft Edge over the raw DevTools protocol with Bun's native
// WebSocket. Playwright doesn't work here: under Bun on Windows both chromium.launch()
// (pipe transport) and connectOverCDP() (its `ws` client) hang, and Node isn't installed.
import { spawn } from "node:child_process"
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { createInterface } from "node:readline"

const base = `http://localhost:${process.env.VITE_PORT ?? "7003"}`
const shots = process.env.MYRA_SHOTS ?? join(process.env.TEMP ?? tmpdir(), "myra-shots")
const edgePath = process.env.MYRA_EDGE ?? "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
const cdpPort = Number(process.env.MYRA_CDP_PORT ?? "9333")
const timeoutMs = 30_000
mkdirSync(shots, { recursive: true })

const profile = mkdtempSync(join(tmpdir(), "myra-edge-"))
const edge = spawn(edgePath, [
  "--headless=new", `--remote-debugging-port=${cdpPort}`, `--user-data-dir=${profile}`,
  "--no-first-run", "--no-default-browser-check", "--disable-extensions",
  "--window-size=1440,900", "about:blank",
], { stdio: "ignore" })

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms))
let target: { webSocketDebuggerUrl: string } | undefined
for (let i = 0; i < 150 && !target; i++) {
  try {
    const list = (await (await fetch(`http://127.0.0.1:${cdpPort}/json/list`)).json()) as any[]
    target = list.find((t) => t.type === "page")
  } catch {}
  if (!target) await sleep(200)
}
if (!target) throw new Error(`Edge did not expose a page on CDP port ${cdpPort}`)

const ws = new WebSocket(target.webSocketDebuggerUrl)
await new Promise((ok, fail) => { ws.onopen = ok; ws.onerror = fail })
let nextId = 0
const pending = new Map<number, { ok: (v: any) => void; fail: (e: Error) => void }>()
const errors: string[] = []
ws.onmessage = (ev) => {
  const msg = JSON.parse(String(ev.data))
  if (msg.id !== undefined) {
    const p = pending.get(msg.id)
    pending.delete(msg.id)
    msg.error ? p?.fail(new Error(msg.error.message)) : p?.ok(msg.result)
  } else if (msg.method === "Runtime.exceptionThrown") {
    errors.push(msg.params.exceptionDetails.exception?.description ?? msg.params.exceptionDetails.text)
  } else if (msg.method === "Runtime.consoleAPICalled" && msg.params.type === "error") {
    errors.push(msg.params.args.map((a: any) => a.value ?? a.description ?? "").join(" "))
  } else if (msg.method === "Network.responseReceived" && msg.params.response.status >= 400) {
    errors.push(`${msg.params.response.status} ${msg.params.response.url}`)
  }
}
const cdp = (method: string, params: object = {}) =>
  new Promise<any>((ok, fail) => {
    const id = ++nextId
    pending.set(id, { ok, fail })
    ws.send(JSON.stringify({ id, method, params }))
  })
const evaluate = async (expression: string) => {
  const r = await cdp("Runtime.evaluate", { expression, awaitPromise: true, returnByValue: true })
  if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description ?? r.exceptionDetails.text)
  return r.result.value
}
const waitUntil = async (expression: string, what: string, ms = timeoutMs) => {
  const end = Date.now() + ms
  while (Date.now() < end) {
    if (await evaluate(expression).catch(() => false)) return
    await sleep(200)
  }
  throw new Error(`timed out after ${ms / 1000}s waiting for ${what}`)
}
const q = (sel: string) => `document.querySelector(${JSON.stringify(sel)})`

await cdp("Page.enable")
await cdp("Runtime.enable")
await cdp("Network.enable")
await cdp("Emulation.setDeviceMetricsOverride", { width: 1440, height: 900, deviceScaleFactor: 1, mobile: false })

let shotIndex = 0
const commands: Record<string, (arg: string) => Promise<string | void>> = {
  nav: async (path) => {
    const url = path.startsWith("http") ? path : base + path
    const mounted = `document.readyState === "complete" && location.href.startsWith(${JSON.stringify(url.split("?")[0])}) && (document.getElementById("root")?.childElementCount ?? 1) > 0`
    await cdp("Page.navigate", { url })
    // Occasionally the first load stays a blank page (React never mounts); one reload fixes it.
    try {
      await waitUntil(mounted, `app mount at ${url}`, 20_000)
    } catch {
      await cdp("Page.reload", { ignoreCache: true })
      await waitUntil(mounted, `app mount at ${url} (after reload)`)
      return `${url} (reloaded once: first load stayed blank)`
    }
    return url
  },
  "wait-for": async (sel) => waitUntil(`!!${q(sel)}`, sel),
  "wait-gone": async (sel) => waitUntil(`!${q(sel)}`, `${sel} to disappear`),
  "wait-text": async (text) => waitUntil(`document.body.innerText.includes(${JSON.stringify(text)})`, `text "${text}"`),
  click: async (sel) => {
    await waitUntil(`!!${q(sel)}`, sel)
    await evaluate(`${q(sel)}.click()`)
  },
  // `fill <selector> :: <text>`. Focus then insertText so React's onChange fires
  // (setting .value directly doesn't).
  fill: async (arg) => {
    const at = arg.indexOf(" :: ")
    if (at < 0) throw new Error('usage: fill <selector> :: <text>')
    const sel = arg.slice(0, at)
    await waitUntil(`!!${q(sel)}`, sel)
    await evaluate(`(() => { const el = ${q(sel)}; el.focus(); el.select?.(); })()`)
    await cdp("Input.insertText", { text: arg.slice(at + 4) })
  },
  press: async (key) => {
    await cdp("Input.dispatchKeyEvent", { type: "keyDown", key, code: key, windowsVirtualKeyCode: key === "Enter" ? 13 : 0 })
    await cdp("Input.dispatchKeyEvent", { type: "keyUp", key, code: key })
  },
  text: async (sel) => String(await evaluate(`(${q(sel || "body")}?.innerText ?? "<not found>")`)).slice(0, 2000),
  eval: async (expr) => JSON.stringify(await evaluate(expr)),
  screenshot: async (name) => {
    const file = join(shots, `${name || String(++shotIndex).padStart(2, "0")}.png`)
    const { data } = await cdp("Page.captureScreenshot", { format: "png" })
    writeFileSync(file, Buffer.from(data, "base64"))
    return file
  },
  errors: async () => (errors.length ? errors.join("\n") : "none"),
  sleep: async (ms) => { await sleep(Number(ms) || 1000) },
}

try {
  for await (const raw of createInterface({ input: process.stdin })) {
    const line = raw.trim()
    if (!line || line.startsWith("#")) continue
    const [cmd, ...rest] = line.split(" ")
    const fn = commands[cmd]
    if (!fn) { console.log(`? unknown command "${cmd}" (${Object.keys(commands).join(", ")})`); continue }
    try {
      const out = await fn(rest.join(" "))
      console.log(`> ${line}${out ? `\n${out}` : ""}`)
    } catch (e) {
      console.log(`! ${line}\n${(e as Error).message.split("\n")[0]}`)
      process.exitCode = 1
    }
  }
} finally {
  ws.close()
  edge.kill()
  await sleep(300)
  try { rmSync(profile, { recursive: true, force: true }) } catch {}
}

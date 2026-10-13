---
name: run-myra
description: Start, stop, build, run, smoke-test and screenshot the Myra stack locally (Postgres/Redis infra, Rust API, worker/syncer, Vite web app). Use when asked to run or start Myra, bring up the backend, worker or web UI, check that the app works, take screenshots of a page, drive the UI, or trigger and watch a connector sync.
---

Myra is a Rust API + background worker (`server/`) plus a React/Vite web app (`web/`), with Postgres, Redis and friends in docker-compose. Agents drive it with two scripts in this directory. **`stack.sh`** starts, stops and checks every process in the background, and **`browse.ts`** is a headless-Edge driver that navigates, clicks, fills, takes screenshots and collects console/network errors. Use `curl` for the API.

All paths are relative to the repo root. Verified on Windows 11 from **Git Bash** (the Bash tool). `make` is not installed on this machine, so the scripts run the Makefile's commands directly.

## Prerequisites

Already present on this machine and required: Docker Desktop, rustup with the `stable-x86_64-pc-windows-msvc` toolchain, `bun`, Git Bash, and Microsoft Edge at `C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe`. Node is **not** installed and isn't needed.

The repo-root `.env` must exist (`make setup-env` creates it from `.secrets`; that step wasn't re-run here). Ports come from `.env`. This checkout uses API **7002**, web **7003** and Postgres **7001**. If yours differ, export `SERVER_PORT` / `VITE_PORT` before calling the scripts, which default to 7002/7003 and never read `.env` themselves.

## Run (agent path)

```bash
bash .claude/skills/run-myra/stack.sh up          # infra + api + worker + web, waits until each is ready
bash .claude/skills/run-myra/stack.sh smoke       # curl 3 API endpoints + screenshot dashboard & ledger; exit 0 = healthy
bash .claude/skills/run-myra/stack.sh status
bash .claude/skills/run-myra/stack.sh logs worker 40   # api | worker | web, ANSI stripped
bash .claude/skills/run-myra/stack.sh down        # stops api, worker, web; add --infra to also stop containers (volumes kept)
```

`up api web` starts only those parts. With cached builds, `up` takes about 40 s. The first Rust build takes about 10 min. Logs go to `/tmp/myra-run/{api,worker,web}.log` (`C:\Users\aiwar\AppData\Local\Temp\myra-run`).

### Drive the web UI

Pipe commands to the driver, one per line:

```bash
bun .claude/skills/run-myra/browse.ts <<'EOF'
nav /transactions
wait-for [data-slot="page-header"]
wait-gone [data-slot="skeleton"]
fill input[placeholder^="Search descriptions"] :: PBR
press Enter
wait-gone [data-slot="skeleton"]
sleep 1500
screenshot ledger-search
text [data-slot="page-header"]
errors
EOF
```

Screenshots land in `C:\Users\aiwar\AppData\Local\Temp\myra-shots\<name>.png` (override with `MYRA_SHOTS`). Open them with the Read tool to actually look at them. Each output line is `> cmd` on success or `! cmd` plus a reason on failure, and the process exits 1 if any command failed.

| command | what it does |
|---|---|
| `nav <path or url>` | go to `http://localhost:$VITE_PORT<path>` and wait for React to mount (reloads once if the page stays blank) |
| `wait-for <css>` / `wait-gone <css>` | wait (30 s) for an element to appear or disappear |
| `wait-text <text>` | wait for text anywhere in the body |
| `click <css>` | `el.click()` on the first match |
| `fill <css> :: <text>` | focus, select, then type via `Input.insertText` (fires React onChange) |
| `press <key>` | key down/up, e.g. `Enter` |
| `text [css]` | innerText (first 2000 chars) of an element, or of the body |
| `eval <js>` | evaluate an expression in the page and print it as JSON |
| `screenshot [name]` | 1440×900 PNG |
| `errors` | console errors, uncaught exceptions and HTTP ≥ 400 responses seen so far |
| `sleep <ms>` | fixed wait |

Ready markers the app exposes: `[data-slot="dashboard"]` (`/`), `[data-slot="page-header"]` (`/transactions`, `/portfolio`, `/accounts`), and `[data-slot="skeleton"]` while data is loading. Always `wait-gone` the skeleton before taking a screenshot.

### API

Auth is `noauth`, so no headers are needed. The default user is `00000000-0000-0000-0000-000000000000`.

```bash
U=00000000-0000-0000-0000-000000000000
curl -s "http://localhost:7002/api/users/$U/accounts"
curl -s "http://localhost:7002/api/users/$U/transactions?page=0&page_size=1"
curl -s -o /dev/null -w '%{http_code}\n' http://localhost:7002/api-docs/openapi.json
```

Trigger a connector sync, which the worker picks up from the queue:

```bash
curl -s -X POST "http://localhost:7002/api/users/$U/connectors/bindings/<binding_id>/sync" -H 'Content-Type: application/json' -d '{}'
bash .claude/skills/run-myra/stack.sh logs worker 80 | grep -E 'projection committed|not imported|job failed'
```

### Database

`psql` isn't installed on the host. Use the container instead:

```bash
docker exec myra-database-1 psql -U myradev -d myra -c "select count(*) from connector_transaction"
```

## Run (human path)

There are four terminals: `docker-compose up -d`, then from `server/` run `cargo +stable-x86_64-pc-windows-msvc run -p api --no-default-features --features noauth,seed`, then `cargo +stable-x86_64-pc-windows-msvc run -p worker`, and from `web/` run `bun run dev`. Open http://localhost:7003. Stop each with Ctrl-C.

## Test

```bash
cd server && cargo +stable-x86_64-pc-windows-msvc test -p connectors   # 52 passed, ~70 s incremental
cd web && bun run typecheck                                            # tsc -b, ~60 s, silent on success
```

## Gotchas

- **Always pass `+stable-x86_64-pc-windows-msvc` to cargo.** The default GNU toolchain is broken here (missing `as.exe`).
- **Playwright doesn't work on this machine.** Under Bun on Windows, `chromium.launch()` (pipe transport) and `chromium.connectOverCDP()` (Playwright's `ws` client) both hang until they time out. That's why `browse.ts` speaks raw CDP over Bun's native `WebSocket`. The project's own `bun run e2e` depends on Playwright, so expect it to have the same problem.
- **Vite listens on `[::1]` only.** `http://127.0.0.1:7003` is refused while `http://localhost:7003` works, so always use `localhost` for the web app. The API listens on `127.0.0.1:7002`.
- **Give every `curl` a timeout (`-m`).** A wedged Vite left behind after its `bun` parent was killed accepted connections but never answered. A curl without a timeout hung the whole `up` script.
- **`[data-slot="dashboard"]` appears before the data does.** A screenshot taken then shows only grey skeletons, so wait for `[data-slot="skeleton"]` to disappear first.
- **First page load sometimes stays blank.** React occasionally doesn't mount on the first navigation (white page, no errors). `nav` detects an empty `#root` and reloads once.
- **`down` kills by image name.** It runs `taskkill /IM api.exe` and `/IM worker.exe`, which also stops API and worker processes from other worktrees.
- **Claude Code reaps background shells when memory runs low.** On a 16 GB machine, API + worker + Vite + rust-analyzer can trigger it, and the processes then disappear without errors in their logs. Check `stack.sh status`, and re-run `up` only when asked.
- **The worker's scheduled sync runs every 30 min** (`:00`/`:30`) and contacts external providers. Stop the worker (`taskkill //IM worker.exe //F`) when you don't want that, e.g. while a provider is rate-limiting you.
- **`.env` is deny-listed for agent reads.** Don't grep it for ports. Pass `SERVER_PORT`/`VITE_PORT` if they aren't 7002/7003.

## Troubleshooting

- **`stack.sh up` hangs after `starting web`.** A stale node/Vite process holds port 7003. Find it with `netstat -ano | grep ':7003 '` and kill it with `taskkill //PID <pid> //T //F`.
- **`TimeoutError: launch: Timeout 180000ms exceeded` / `connectOverCDP: Timeout 30000ms exceeded`.** Playwright is running under Bun; use `browse.ts` instead.
- **Screenshot is a blank white page and `wait-for` timed out.** That was the first-load blank page. The current `nav` retries automatically; if it still fails, check `stack.sh logs web` and `errors`.
- **Worker log shows `error sending request for url (http://localhost:7009/rates/history)` every minute.** The private `market-data-api` isn't running. It's harmless for everything except asset price history.

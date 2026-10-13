#!/usr/bin/env bash
# Start / stop / inspect the local Myra stack (infra, API, worker, web) from Git Bash on Windows.
# Usage: stack.sh up [api|worker|web ...] | down [--infra] | status | smoke | logs <api|worker|web> [lines]
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SERVER_PORT="${SERVER_PORT:-7002}"
VITE_PORT="${VITE_PORT:-7003}"
LOG_DIR="${MYRA_LOG_DIR:-${TMPDIR:-/tmp}/myra-run}"
TOOLCHAIN="${MYRA_TOOLCHAIN:-+stable-x86_64-pc-windows-msvc}"
mkdir -p "$LOG_DIR"

log() { printf '[stack] %s\n' "$*"; }
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }
port_pid() { netstat -ano | awk -v p=":$1" '$2 ~ p"$" && $4 == "LISTENING" {print $5; exit}'; }
running() { tasklist //FI "IMAGENAME eq $1" 2>/dev/null | grep -qi "$1"; }

wait_for() { # wait_for <seconds> <description> <command...>
  local secs=$1 what=$2; shift 2
  for _ in $(seq 1 "$secs"); do "$@" >/dev/null 2>&1 && return 0; sleep 1; done
  log "timed out after ${secs}s waiting for $what"; return 1
}

start_infra() {
  (cd "$ROOT" && docker-compose up -d 2>&1 | grep -vE 'VAULT_(PORT|TOKEN)' | grep -E 'Started|Running|Error|error' || true)
  wait_for 60 "postgres" docker exec myra-database-1 pg_isready -U myradev -d myra
}

start_api() {
  if [ -n "$(port_pid "$SERVER_PORT")" ]; then log "api already listening on $SERVER_PORT"; return 0; fi
  log "starting api (first build ~10 min, cached ~30 s) -> $LOG_DIR/api.log"
  (cd "$ROOT/server" && nohup cargo $TOOLCHAIN run -p api --no-default-features --features noauth,seed </dev/null >"$LOG_DIR/api.log" 2>&1 &)
  wait_for 1200 "api on :$SERVER_PORT" curl -sf -m 5 -o /dev/null "http://localhost:$SERVER_PORT/redoc" || { tail -20 "$LOG_DIR/api.log" | strip_ansi; return 1; }
  log "api up: http://localhost:$SERVER_PORT/api (docs: /redoc)"
}

start_worker() {
  if running worker.exe; then log "worker already running"; return 0; fi
  log "starting worker -> $LOG_DIR/worker.log"
  (cd "$ROOT/server" && nohup cargo $TOOLCHAIN run -p worker </dev/null >"$LOG_DIR/worker.log" 2>&1 &)
  wait_for 1200 "worker start" grep -q "worker starting" "$LOG_DIR/worker.log" || { tail -20 "$LOG_DIR/worker.log" | strip_ansi; return 1; }
  log "worker up"
}

start_web() {
  if [ -n "$(port_pid "$VITE_PORT")" ]; then log "web already listening on $VITE_PORT"; return 0; fi
  log "starting web (vite) -> $LOG_DIR/web.log"
  (cd "$ROOT/web" && nohup bun run dev </dev/null >"$LOG_DIR/web.log" 2>&1 &)
  wait_for 120 "web on :$VITE_PORT" curl -sf -m 5 -o /dev/null "http://localhost:$VITE_PORT/" || { tail -20 "$LOG_DIR/web.log"; return 1; }
  log "web up: http://localhost:$VITE_PORT/"
}

status() {
  printf '%-8s %s\n' infra "$(docker ps --filter name=myra- --format '{{.Names}}' | tr '\n' ' ')"
  printf '%-8s %s\n' api "$(curl -s -m 15 -o /dev/null -w '%{http_code}' "http://localhost:$SERVER_PORT/redoc") (:$SERVER_PORT pid $(port_pid "$SERVER_PORT"))"
  printf '%-8s %s\n' worker "$(running worker.exe && echo running || echo stopped)"
  printf '%-8s %s\n' web "$(curl -s -m 15 -o /dev/null -w '%{http_code}' "http://localhost:$VITE_PORT/") (:$VITE_PORT pid $(port_pid "$VITE_PORT"))"
}

down() {
  taskkill //IM api.exe //F >/dev/null 2>&1 && log "api stopped"
  taskkill //IM worker.exe //F >/dev/null 2>&1 && log "worker stopped"
  local pid; pid="$(port_pid "$VITE_PORT")"
  [ -n "$pid" ] && taskkill //PID "$pid" //T //F >/dev/null 2>&1 && log "web stopped"
  [ "${1:-}" = "--infra" ] && (cd "$ROOT" && docker-compose stop >/dev/null 2>&1) && log "infra stopped (volumes kept)"
  return 0
}

smoke() {
  local u=00000000-0000-0000-0000-000000000000 fail=0 code
  for path in "/api/users/$u/accounts" "/api/users/$u/transactions?page=0&page_size=1" "/api-docs/openapi.json"; do
    code=$(curl -s -m 15 -o /dev/null -w '%{http_code}' "http://localhost:$SERVER_PORT$path")
    printf '%-8s %s %s\n' api "$code" "$path"; [ "$code" = 200 ] || fail=1
  done
  (cd "$ROOT" && bun .claude/skills/run-myra/browse.ts <<'EOF') || fail=1
nav /
wait-for [data-slot="dashboard"]
wait-gone [data-slot="skeleton"]
screenshot dashboard
nav /transactions
wait-for [data-slot="page-header"]
wait-gone [data-slot="skeleton"]
screenshot ledger
errors
EOF
  return $fail
}

case "${1:-}" in
  up)
    shift; parts=("$@"); [ ${#parts[@]} -eq 0 ] && parts=(api worker web)
    start_infra || exit 1
    for p in "${parts[@]}"; do "start_$p" || exit 1; done
    status ;;
  down) down "${2:-}" ;;
  status) status ;;
  smoke) smoke ;;
  logs) tail -n "${3:-40}" "$LOG_DIR/${2:?api|worker|web}.log" | strip_ansi ;;
  *) echo "usage: $0 up [api|worker|web ...] | down [--infra] | status | smoke | logs <api|worker|web> [lines]"; exit 2 ;;
esac

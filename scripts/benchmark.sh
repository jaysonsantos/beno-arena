#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" ]]; then
  exec devenv shell -- bash scripts/benchmark.sh "$@"
fi
bash scripts/build-page.sh
(cd tests/render && beni build --release)
browser="${CHROMIUM_PATH:-chromium}"
mkdir -p .scratch/benchmark
python3 -u -m http.server 0 --bind 127.0.0.1 --directory build/page > .scratch/benchmark/server.log 2>&1 &
server_pid=$!
stop_server() {
  if kill -0 "$server_pid" 2>/dev/null; then
    server_command=$(ps -p "$server_pid" -o args=)
    server_parent=$(ps -p "$server_pid" -o ppid= | tr -d ' ')
    case "$server_command" in
      *"-m http.server 0 --bind 127.0.0.1 --directory build/page"*)
        if [[ "$server_parent" == "$$" ]]; then
          echo "Stop owned server $server_pid: $server_command"
          kill "$server_pid"
        fi
        ;;
    esac
  fi
  wait "$server_pid" 2>/dev/null || true
}
trap stop_server EXIT
port=""
for _ in {1..50}; do
  port=$(sed -n 's/.* port \([0-9]*\) .*/\1/p' .scratch/benchmark/server.log | head -1)
  if [[ -n "$port" ]]; then break; fi
  if ! kill -0 "$server_pid" 2>/dev/null; then
    cat .scratch/benchmark/server.log >&2
    exit 1
  fi
  sleep 0.1
done
test -n "$port"

set +e
timeout --foreground -k 2 9 env -u LD_LIBRARY_PATH "$browser" --headless --disable-gpu --no-sandbox \
  --user-data-dir="$PWD/.scratch/benchmark/profile" \
  --remote-debugging-address=127.0.0.1 --remote-debugging-port=0 \
  --trace-startup --trace-startup-duration=5 --trace-startup-format=json \
  --trace-startup-categories=devtools.timeline,blink,cc \
  --trace-startup-file="$PWD/.scratch/benchmark/trace.json" \
  "http://127.0.0.1:$port/benchmark/" > .scratch/benchmark/chromium.log 2>&1
browser_result=$?
set -e
if [[ "$browser_result" != "0" && "$browser_result" != "124" ]]; then
  cat .scratch/benchmark/chromium.log >&2
  exit "$browser_result"
fi
jq '
  def summary: sort | {samples: length, p50_ms: .[(length * 0.50 | floor)], p95_ms: .[(length * 0.95 | floor)], max_ms: max};
  [.traceEvents[] | select(.name == "FireAnimationFrame" and .ph == "X")] | sort_by(.ts) as $frames |
  if ($frames | length) < 20 then error("Too few animation frames in the trace.") else
    {frame_gap: ([range(1; $frames | length) as $i | ($frames[$i].ts - $frames[$i - 1].ts) / 1000] | summary),
      callback_work: ([$frames[].dur / 1000] | summary),
      snakes: 16, body_samples: 2880, food: 600}
  end
' .scratch/benchmark/trace.json | tee .scratch/benchmark/result.json

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/test-browser.sh "$@"
fi
bash scripts/build-page.sh

# Parse every compiler-generated module with the runtime from the dev shell.
while IFS= read -r -d '' module; do
  node --check "$module"
done < <(find build/page -name '*.mjs' -print0)
test -s build/page/style.css
if grep -q '{{entry}}' build/page/index.html; then
  echo 'The compiler did not replace the entry marker.' >&2
  exit 1
fi

# Check the actual browser render without hand-written JavaScript.
browser="${CHROMIUM_PATH:-chromium}"
if ! command -v "$browser" >/dev/null; then
  echo 'Set CHROMIUM_PATH to a Chromium binary to run the browser check.' >&2
  exit 1
fi
mkdir -p .scratch/browser
python3 -u -m http.server 0 --bind 127.0.0.1 --directory build/page > .scratch/browser/server.log 2>&1 &
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
  port=$(sed -n 's/.* port \([0-9]*\) .*/\1/p' .scratch/browser/server.log | head -1)
  if [[ -n "$port" ]]; then break; fi
  if ! kill -0 "$server_pid" 2>/dev/null; then
    cat .scratch/browser/server.log >&2
    exit 1
  fi
  sleep 0.1
done
test -n "$port"
env -u LD_LIBRARY_PATH "$browser" --headless --disable-gpu --no-sandbox \
  --user-data-dir="$PWD/.scratch/browser/profile" --virtual-time-budget=2500 \
  --window-size=1440,1080 --screenshot="$PWD/.scratch/browser/desktop.png" \
  --dump-dom "http://127.0.0.1:$port" \
  > .scratch/browser/page.html 2> .scratch/browser/chromium.log
grep -q 'Little trouble' .scratch/browser/page.html
grep -q 'Choose Enter arena to connect.' .scratch/browser/page.html
grep -q 'snake-player' .scratch/browser/page.html
grep -q 'Enter arena' .scratch/browser/page.html
env -u LD_LIBRARY_PATH "$browser" --headless --disable-gpu --no-sandbox \
  --user-data-dir="$PWD/.scratch/browser/profile" --virtual-time-budget=2500 \
  --window-size=390,1900 --screenshot="$PWD/.scratch/browser/mobile.png" \
  "http://127.0.0.1:$port" > /dev/null 2>> .scratch/browser/chromium.log
echo 'PASS: release build, module syntax, assets, and browser render.'

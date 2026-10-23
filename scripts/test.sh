#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" || -z "${BENI_MINIFLARE:-}" ]]; then
  exec nix develop .#workers --command bash scripts/test.sh "$@"
fi
bash scripts/test-rules.sh
bash scripts/build-worker.sh
node --check build/worker/_worker.mjs
worker_result=0
bash scripts/test-worker.sh || worker_result=$?
bash scripts/test-browser.sh
exit "$worker_result"

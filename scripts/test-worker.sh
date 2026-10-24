#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" || -z "${BENI_MINIFLARE:-}" ]]; then
  exec devenv shell -- bash scripts/test-worker.sh "$@"
fi
: "${BENI_MINIFLARE:?Enter the workers development shell.}"
: "${BENI_SOURCE:?Enter the pinned development shell.}"
mkdir -p .scratch/workers
(cd tests/transcript && beni build --release)
test_result=0
for mode in development release; do
  options=(--test-hooks --out="$PWD/build/worker-test")
  if [[ "$mode" == "release" ]]; then options+=(--release); fi
  (cd tests/worker-trace && beni build "${options[@]}")
  node "$BENI_SOURCE/tests/workers/driver.mjs" "$PWD/build/worker-test" \
    tests/workers/arena.steps > ".scratch/workers/$mode.log"
  cp ".scratch/workers/$mode.log" .scratch/workers/current.log
  node "$BENI_SOURCE/tests/workers/driver.mjs" "$PWD/build/worker-test" \
    tests/workers/storage.steps > ".scratch/workers/storage-$mode.log"
  cp ".scratch/workers/storage-$mode.log" .scratch/workers/storage-current.log
  echo "Check $mode Worker transcript."
  if ! node build/transcript-tests/_main.mjs; then test_result=1; fi
done
exit "$test_result"

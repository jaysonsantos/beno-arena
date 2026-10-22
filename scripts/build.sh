#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/build.sh "$@"
fi
bash scripts/build-page.sh
bash scripts/build-worker.sh

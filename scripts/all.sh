#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/all.sh "$@"
fi
bash scripts/lint.sh
bash scripts/test.sh

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/test-rules.sh "$@"
fi
(cd tests/rules && beni build --release)
exec node build/rules-tests/_main.mjs

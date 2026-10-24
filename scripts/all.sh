#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" || -z "${BENI_MINIFLARE:-}" ]]; then
  exec devenv shell -- bash scripts/all.sh "$@"
fi
bash scripts/lint.sh
bash scripts/test.sh

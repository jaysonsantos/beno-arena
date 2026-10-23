#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop .#workers --command bash scripts/deploy.sh "$@"
fi
exec wrangler deploy --env production "$@"

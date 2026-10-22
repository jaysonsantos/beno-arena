#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" || -z "${BENI_MINIFLARE:-}" ]]; then
  exec nix develop .#workers --command bash scripts/dev.sh "$@"
fi
bash scripts/build.sh
export CLOUDFLARE_CF_FETCH_ENABLED=false
export WRANGLER_SEND_METRICS=false
exec wrangler dev --local --ip 127.0.0.1 --port "${SNAKE_PORT:-4173}"

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/dev.sh "$@"
fi
bash scripts/build.sh
exec python3 -m http.server "${SNAKE_PORT:-4173}" --bind 127.0.0.1 --directory build/page

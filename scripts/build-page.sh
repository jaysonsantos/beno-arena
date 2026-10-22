#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/build-page.sh "$@"
fi
beni build --release
cp frontend/style.css build/page/style.css
mkdir -p build/page/fonts
cp frontend/fonts/* build/page/fonts/

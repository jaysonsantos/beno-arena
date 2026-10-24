#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${BENO_TOOLCHAIN:-}" != "1" ]]; then
  exec devenv shell -- bash scripts/build-page.sh "$@"
fi
beni build --release --source-maps
cp frontend/style.css build/page/style.css
mkdir -p build/page/fonts
cp frontend/fonts/* build/page/fonts/

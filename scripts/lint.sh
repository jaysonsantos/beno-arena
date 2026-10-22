#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "${SNAKE_TOOLCHAIN:-}" != "1" ]]; then
  exec nix develop --command bash scripts/lint.sh "$@"
fi
export PREK_HOME="$PWD/.scratch/prek"
mkdir -p "$PREK_HOME"
exec prek run --all-files

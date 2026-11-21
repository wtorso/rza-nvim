#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v nvim >/dev/null 2>&1; then
    echo "FATAL: nvim is required" >&2
    exit 2
fi

nvim --headless -u NONE -i NONE -n -l test/setup.lua
printf '\n'
nvim --headless -u NONE -i NONE -n -l test/nvim.lua
printf '\n'
if [ -n "${RZA_COMPILER:-}" ]; then
    if [ ! -x "$RZA_COMPILER" ]; then
        echo "FATAL: RZA_COMPILER is not executable: $RZA_COMPILER" >&2
        exit 2
    fi
    nvim --headless -u NONE -i NONE -n -l test/lsp.lua
    printf '\n'
else
    printf 'Neovim LSP integration not requested (RZA_COMPILER is unset)\n'
fi

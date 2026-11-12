#! /usr/bin/env bash

set -euo pipefail
config_source="$(cd -- "$(dirname -- "$0")" && pwd)/vim"
mkdir -p "$HOME/.vim"
cp -f -v "$config_source/.vimrc" "$HOME/.vimrc"
cp -f -v "$config_source/.vimrc.local" "$HOME/.vimrc.local"
cp -f -v "$config_source/coc.vim" "$HOME/.vim/coc.vim"
cp -f -v "$config_source/coc-settings.json" "$HOME/.vim/coc-settings.json"

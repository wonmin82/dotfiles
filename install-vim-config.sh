#! /usr/bin/env bash

set -euo pipefail
shopt -s nullglob

backup_requested=0
case "${1-}" in
    '') ;;
    --backup) backup_requested=1; shift ;;
    *) printf 'Usage: %s [--backup]\n' "$0" >&2; exit 2 ;;
esac
if (( $# != 0 )); then
    printf 'Usage: %s [--backup]\n' "$0" >&2
    exit 2
fi

config_source="$(cd -- "$(dirname -- "$0")" && pwd -P)/vim"
runtime="$HOME/.vim/dotvim"
runtime_files=(
    "$config_source"/config/*.vim
    "$config_source"/config/clang-format/*.vim
    "$config_source"/autoload/dotvim/*.vim
    "$config_source"/autoload/xolox/*.vim
    "$config_source"/coc.vim
)
managed_sources=("${runtime_files[@]}" "$config_source/.vimrc")
managed_targets=()
for file in "${runtime_files[@]}"; do
    managed_targets+=("$runtime/${file#"$config_source"/}")
done
managed_targets+=("$HOME/.vimrc")

# Avoid writing through a customized runtime directory or Vim directory link.
for dir in "$HOME/.vim" "$runtime" "$runtime/config" "$runtime/config/clang-format" \
    "$runtime/autoload" "$runtime/autoload/dotvim" "$runtime/autoload/xolox"; do
    if [[ -L "$dir" || ( -e "$dir" && ! -d "$dir" ) ]]; then
        printf 'Expected a real directory at %s\n' "$dir" >&2
        exit 1
    fi
done

mkdir -p "$HOME/.vim"
lock="$HOME/.vim/.dotvim-install-lock"
if ! mkdir "$lock"; then
    printf 'Another Vim installation may be in progress at %s\n' "$lock" >&2
    exit 1
fi
staged=''
cleanup() {
    if [[ -n "$staged" ]]; then
        rm -f -- "$staged"
    fi
    rmdir -- "$lock"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

conflicts=()
for index in "${!managed_sources[@]}"; do
    file="${managed_sources[index]}"
    target="${managed_targets[index]}"
    if [[ ! -f "$file" ]]; then
        printf 'Missing source file %s\n' "$file" >&2
        exit 1
    fi
    if [[ -L "$target" || ( -e "$target" && ! -f "$target" ) ]]; then
        printf 'Move the existing path before installing %s\n' "$target" >&2
        exit 1
    fi
    if [[ -e "$target" ]] && ! cmp -s "$file" "$target"; then
        conflicts+=("$target")
    fi
done

if (( ${#conflicts[@]} )); then
    if (( ! backup_requested )); then
        printf 'Existing configuration differs. Review these files or rerun with --backup to replace them.\n' >&2
        printf '  %s\n' "${conflicts[@]}" >&2
        exit 1
    fi
    backup="$(mktemp -d "$HOME/.dotvim-backup.XXXXXXXX")"
    printf 'Saving previous configuration in %s\n' "$backup"
    for target in "${conflicts[@]}"; do
        relative="${target#"$HOME"/}"
        mkdir -p -- "$backup/$(dirname -- "$relative")"
        cp -p -- "$target" "$backup/$relative"
    done
fi

install_file() {
    local file="$1" target="$2" directory
    if [[ -f "$target" ]] && cmp -s "$file" "$target"; then
        return
    fi
    directory="$(dirname -- "$target")"
    mkdir -p -- "$directory"
    staged="$(mktemp "$directory/.dotvim.XXXXXXXX")"
    cp -- "$file" "$staged"
    mv -f -- "$staged" "$target"
    staged=''
}

# These files belong to the user once created.
for relative in .vimrc.local .vim/coc-settings.json; do
    target="$HOME/$relative"
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        install_file "$config_source/${relative##*/}" "$target"
    fi
done

# Install the loader last so an interrupted first run keeps the old vimrc.
for index in "${!managed_sources[@]}"; do
    install_file "${managed_sources[index]}" "${managed_targets[index]}"
done

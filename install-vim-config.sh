#! /usr/bin/env bash

set -euo pipefail
shopt -s nullglob

usage() {
    printf 'Usage: %s [--backup | --skip-existing] [--dry-run]\n' "$0" >&2
}

backup_requested=0
skip_existing=0
dry_run=0
while (( $# )); do
    case "$1" in
        --backup) backup_requested=1 ;;
        --skip-existing) skip_existing=1 ;;
        --dry-run) dry_run=1 ;;
        *) usage; exit 2 ;;
    esac
    shift
done
if (( backup_requested && skip_existing )); then
    usage
    exit 2
fi

script_dir="$(cd -- "$(dirname -- "$0")" && pwd -P)"
source "$script_dir/lib/install-output.sh"
config_source="$script_dir/vim"
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

lock="$HOME/.vim/.dotvim-install-lock"
staged=''
backup=''
cleanup() {
    if [[ -n "$staged" ]]; then
        rm -f -- "$staged"
    fi
    rmdir -- "$lock"
}
if (( ! dry_run )); then
    mkdir -p -- "$HOME/.vim"
    if ! mkdir -- "$lock"; then
        printf 'Another Vim installation may be in progress at %s\n' "$lock" >&2
        exit 1
    fi
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
fi

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

status=0
if (( ${#conflicts[@]} )); then
    if (( skip_existing )); then
        printf 'Warning: Preserved Vim files may be incompatible with the shipped runtime. Review the differing files before using the combined configuration.\n' >&2
    elif (( ! backup_requested )); then
        printf 'Existing configuration differs. Review the skipped files or rerun with --backup to replace them.\n' >&2
        status=1
    elif (( ! dry_run )); then
        backup="$(mktemp -d "$HOME/.dotvim-backup.XXXXXXXX")"
        printf 'Saving previous configuration in %s\n' "$backup"
        for target in "${conflicts[@]}"; do
            relative="${target#"$HOME"/}"
            mkdir -p -- "$backup/$(dirname -- "$relative")"
            cp -p -- "$target" "$backup/$relative"
        done
    fi
fi

install_file() {
    local file="$1" target="$2" directory action=NEW detail='' backup_file
    if [[ -f "$target" ]]; then
        if cmp -s "$file" "$target"; then
            report_file SKIP "$target" 'already matches' "$dry_run"
            return
        fi
        if (( skip_existing || status )); then
            report_file SKIP "$target" 'existing file differs' "$dry_run"
            return
        fi
        action=OVERWRITE
        if (( dry_run )); then
            detail='backup planned'
        fi
    elif (( status )); then
        report_file SKIP "$target" 'existing Vim configuration has conflicts' "$dry_run"
        return
    fi
    if (( ! dry_run )); then
        directory="$(dirname -- "$target")"
        mkdir -p -- "$directory"
        staged="$(mktemp "$directory/.dotvim.XXXXXXXX")"
        cp -- "$file" "$staged"
        mv -f -- "$staged" "$target"
        staged=''
        if [[ -n "$backup" ]]; then
            backup_file="$backup/${target#"$HOME"/}"
            if [[ -f "$backup_file" ]]; then
                detail="backup at $backup_file"
            fi
        fi
    fi
    report_file "$action" "$target" "$detail" "$dry_run"
}

# These files belong to the user once created.
for relative in .vimrc.local .vim/coc-settings.json; do
    target="$HOME/$relative"
    if [[ -e "$target" || -L "$target" ]]; then
        report_file SKIP "$target" 'user-managed file' "$dry_run"
    else
        install_file "$config_source/${relative##*/}" "$target"
    fi
done

# Install the loader last so an interrupted first run keeps the old vimrc.
for index in "${!managed_sources[@]}"; do
    install_file "${managed_sources[index]}" "${managed_targets[index]}"
done
exit "$status"

#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf 'Usage: %s [-n|--dry-run] [-f|--force]\n' "${0##*/}"
    printf 'Install missing files. Use --force to back up and replace differing files.\n'
}

dry_run=0
force=0
while (( $# )); do
    case "$1" in
        -n|--dry-run) dry_run=1 ;;
        -f|--force) force=1 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done

if [[ $(uname -s) != Darwin ]] || (( EUID == 0 )); then
    printf 'Run this installer on macOS as your regular user.\n' >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "$0")" && pwd -P)"
config_files=(
    'ubuntu/.gitconfig:.gitconfig'
    'ubuntu/.tmux.conf:.tmux.conf'
    'ubuntu/.curlrc:.curlrc'
    'ubuntu/.wgetrc:.wgetrc'
    'ubuntu/flake8:.config/flake8'
    'ubuntu/pip.conf:.config/pip/pip.conf'
)

lock="$HOME/.dotfiles-mac-install-lock"
staged=''
backup=''
cleanup() {
    if [[ -n "$staged" ]]; then
        rm -f -- "$staged"
    fi
    rmdir -- "$lock"
}

if (( ! dry_run )); then
    if ! mkdir -- "$lock"; then
        printf 'Cannot acquire the macOS configuration install lock at %s\n' "$lock" >&2
        exit 1
    fi
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
fi

for dir in "$HOME/.config" "$HOME/.config/pip"; do
    if [[ -L "$dir" || ( -e "$dir" && ! -d "$dir" ) ]]; then
        printf 'Expected a real directory at %s\n' "$dir" >&2
        exit 1
    fi
done
for entry in "${config_files[@]}"; do
    src="$script_dir/${entry%%:*}"
    target="$HOME/${entry#*:}"
    if [[ ! -f "$src" ]]; then
        printf 'Missing source file %s\n' "$src" >&2
        exit 1
    fi
    if [[ -L "$target" || ( -e "$target" && ! -f "$target" ) ]]; then
        printf 'Expected a regular file at %s\n' "$target" >&2
        exit 1
    fi
done

installer_args=(--skip-existing)
if (( force )); then
    installer_args=(--backup)
fi
if (( dry_run )); then
    installer_args+=(--dry-run)
fi
/bin/bash "$script_dir/install-vim-config.sh" "${installer_args[@]}"
/bin/bash "$script_dir/install-zsh-config.sh" --macos "${installer_args[@]}"

for entry in "${config_files[@]}"; do
    src="$script_dir/${entry%%:*}"
    relative="${entry#*:}"
    target="$HOME/$relative"
    backup_file=''
    if [[ -f "$target" ]]; then
        if cmp -s "$src" "$target"; then
            printf 'Skipped %s (already matches)\n' "$target"
            continue
        fi
        if (( ! force )); then
            printf 'Skipped %s (existing file differs)\n' "$target"
            continue
        fi
        if (( dry_run )); then
            printf 'Would back up and install %s\n' "$target"
            continue
        fi
        if [[ -z "$backup" ]]; then
            backup="$(mktemp -d "$HOME/.dotfiles-mac-backup.XXXXXXXX")"
            printf 'Saving previous configuration in %s\n' "$backup"
        fi
        backup_file="$backup/$relative"
        mkdir -p -- "$(dirname -- "$backup_file")"
        cp -p -- "$target" "$backup_file"
    elif (( dry_run )); then
        printf 'Would install %s\n' "$target"
        continue
    fi

    dir="$(dirname -- "$target")"
    mkdir -p -- "$dir"
    staged="$(mktemp "$dir/.dotfiles-mac.XXXXXXXX")"
    /usr/bin/install -m 644 "$src" "$staged"
    mv -f -- "$staged" "$target"
    staged=''
    if [[ -n "$backup_file" ]]; then
        printf 'Backed up and installed %s (backup at %s)\n' "$target" "$backup_file"
    else
        printf 'Installed %s\n' "$target"
    fi
done

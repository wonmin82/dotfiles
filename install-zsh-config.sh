#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf 'Usage: %s [--macos] [--backup | --skip-existing] [--dry-run]\n' "${0##*/}"
    printf 'Use --macos to install macOS settings without changing the login shell.\n'
}

macos=0
backup_requested=0
skip_existing=0
dry_run=0
while (( $# )); do
    case "$1" in
        --macos) macos=1 ;;
        --backup) backup_requested=1 ;;
        --skip-existing) skip_existing=1 ;;
        --dry-run) dry_run=1 ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done
if (( backup_requested && skip_existing )); then
    usage >&2
    exit 2
fi

script_dir="$(cd -- "$(dirname -- "$0")" && pwd -P)"
os="$(uname -s)"
terminals=(xterm-256color screen-256color)
entries=()
change_shell=0
if (( macos )); then
    if [[ $os != Darwin ]]; then
        printf 'The --macos option requires macOS.\n' >&2
        exit 1
    fi
    zsh_platform="$(/bin/zsh -dfc 'print -r -- "$VENDOR-$OSTYPE"')"
    entries+=('file:.zprofile.macos:.zsh/.zprofile')
    for terminal in "${terminals[@]}"; do
        entries+=("file:.zkbd/$terminal-apple-darwin18.0:.zsh/.zkbd/$terminal-$zsh_platform")
    done
else
    for terminal in "${terminals[@]}"; do
        for platform in ubuntu-linux-gnu pc-linux-gnu apple-darwin18.0; do
            entries+=("file:.zkbd/$terminal-$platform:.zsh/.zkbd/$terminal-$platform")
        done
        entries+=("link:.zsh/.zkbd/$terminal-ubuntu-linux-gnu:.zsh/.zkbd/$terminal-unknown-linux-gnu")
    done

    current_user="$(id -un)"
    if [[ $os == Darwin ]]; then
        current_shell="$(dscacheutil -q user -a name "$current_user" | awk '$1 == "shell:" { print $2 }')"
    else
        current_shell="$(awk -F: -v user="$current_user" '$1 == user { print $7; exit }' /etc/passwd)"
    fi
    if [[ -z "$current_shell" ]]; then
        printf 'Could not determine the login shell for %s\n' "$current_user" >&2
        exit 1
    fi
    if [[ ${current_shell##*/} != zsh ]]; then
        if [[ -e /etc/synoinfo.conf ]]; then
            entries+=('file:.profile.synology:.profile')
        else
            change_shell=1
        fi
    fi
fi

# Install ZDOTDIR and its configuration before enabling its loader.
entries+=('file:.zshrc:.zsh/.zshrc' 'file:.zshenv:.zshenv')

lock="$HOME/.dotfiles-zsh-install-lock"
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
        printf 'Cannot acquire the Zsh configuration install lock at %s\n' "$lock" >&2
        exit 1
    fi
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
fi

for dir in "$HOME/.zsh" "$HOME/.zsh/.zkbd"; do
    if [[ -L "$dir" || ( -e "$dir" && ! -d "$dir" ) ]]; then
        printf 'Expected a real directory at %s\n' "$dir" >&2
        exit 1
    fi
done

for entry in "${entries[@]}"; do
    kind="${entry%%:*}"
    paths="${entry#*:}"
    source_file="$script_dir/zsh/${paths%%:*}"
    target="$HOME/${paths#*:}"
    if [[ $kind == file && ! -f "$source_file" ]]; then
        printf 'Missing source file %s\n' "$source_file" >&2
        exit 1
    fi
    if [[ $kind == link && -L "$target" ]]; then
        continue
    fi
    if [[ -L "$target" || ( -e "$target" && ! -f "$target" ) ]]; then
        printf 'Expected a regular file at %s\n' "$target" >&2
        exit 1
    fi
done

for entry in "${entries[@]}"; do
    kind="${entry%%:*}"
    paths="${entry#*:}"
    source_path="${paths%%:*}"
    relative="${paths#*:}"
    target="$HOME/$relative"
    backup_file=''
    if [[ $kind == file ]]; then
        source_path="$script_dir/zsh/$source_path"
        if [[ -f "$target" ]] && cmp -s "$source_path" "$target"; then
            printf 'Skipped %s (already matches)\n' "$target"
            continue
        fi
    else
        source_path="$HOME/$source_path"
        if [[ -L "$target" && $(readlink "$target") == "$source_path" ]]; then
            printf 'Skipped %s (already matches)\n' "$target"
            continue
        fi
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        if (( skip_existing )); then
            printf 'Skipped %s (existing file differs)\n' "$target"
            continue
        fi
        if (( dry_run )); then
            if (( backup_requested )); then
                printf 'Would back up and install %s\n' "$target"
            else
                printf 'Would replace %s\n' "$target"
            fi
            continue
        fi
        if (( backup_requested )); then
            if [[ -z "$backup" ]]; then
                backup="$(mktemp -d "$HOME/.dotfiles-zsh-backup.XXXXXXXX")"
                printf 'Saving previous configuration in %s\n' "$backup"
            fi
            backup_file="$backup/$relative"
            mkdir -p -- "$(dirname -- "$backup_file")"
            cp -pP -- "$target" "$backup_file"
        fi
    elif (( dry_run )); then
        printf 'Would install %s\n' "$target"
        continue
    fi

    dir="$(dirname -- "$target")"
    mkdir -p -- "$dir"
    if [[ $kind == file ]]; then
        staged="$(mktemp "$dir/.dotfiles-zsh.XXXXXXXX")"
        cp -- "$source_path" "$staged"
        chmod 644 "$staged"
        mv -f -- "$staged" "$target"
        staged=''
    else
        ln -sfn -- "$source_path" "$target"
    fi
    if [[ -n "$backup_file" ]]; then
        printf 'Backed up and installed %s (backup at %s)\n' "$target" "$backup_file"
    else
        printf 'Installed %s\n' "$target"
    fi
done

if (( change_shell )); then
    if (( dry_run )); then
        printf 'Would set the login shell for %s to /bin/zsh\n' "$current_user"
    else
        sudo chsh -s /bin/zsh "$current_user"
    fi
fi

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
    entries+=('file:homebrew.zsh:.zsh/homebrew.zsh' 'file:.zprofile.macos:.zsh/.zprofile')
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

target_dirs=("$HOME/.zsh")
if (( ! macos )); then
    target_dirs+=("$HOME/.zsh/.zkbd")
fi
for dir in "${target_dirs[@]}"; do
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
    if (( macos && skip_existing )) && [[ $target == "$HOME/.zshenv" && -L "$target" ]]; then
        continue
    fi
    if [[ -L "$target" || ( -e "$target" && ! -f "$target" ) ]]; then
        printf 'Expected a regular file at %s\n' "$target" >&2
        exit 1
    fi
done

would_install_zshenv=0
for entry in "${entries[@]}"; do
    kind="${entry%%:*}"
    paths="${entry#*:}"
    source_path="${paths%%:*}"
    relative="${paths#*:}"
    target="$HOME/$relative"
    backup_file=''
    if (( macos && skip_existing )) && [[ $relative == .zshenv && -L "$target" ]]; then
        printf 'Skipped %s (existing symbolic link)\n' "$target"
        continue
    fi
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
            if [[ $relative == .zshenv ]]; then
                would_install_zshenv=1
            fi
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
        if [[ $relative == .zshenv ]]; then
            would_install_zshenv=1
        fi
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

report_macos_zdotdir() {
    local shell_path result effective='' rcs='' phase='after installation' target_dir
    target_dir="$(cd -- "$HOME" && pwd -P)/.zsh"
    shell_path="$(type -P zsh || printf /bin/zsh)"
    if (( dry_run )); then
        phase='before installation'
    fi

    # Evaluate only early startup in a read-only sandbox, with no network or terminal.
    if [[ -x /usr/bin/sandbox-exec && -x /usr/bin/perl ]] &&
        result=$(/usr/bin/perl -e 'alarm 3; exec @ARGV or die $!;' /usr/bin/sandbox-exec -p \
            '(version 1) (deny default) (allow file-read* process-exec process-fork sysctl-read) (allow file-write-data (literal "/dev/null"))' \
            "$shell_path" -dc '
                dotdir=${ZDOTDIR-$HOME}
                print -ru3 -- "$options[rcs]" "${${dotdir:-/}:A}"
            ' \
            3>&1 </dev/null >/dev/null 2>&1); then
        case "$result" in
            'on /'*|'off /'*)
                rcs=${result%% *}
                effective=${result#* }
                ;;
        esac
    fi

    if [[ -n $effective ]]; then
        printf 'ZDOTDIR %s %s (early startup with %s)\n' "$phase" "$effective" "$shell_path"
    else
        printf 'ZDOTDIR %s could not be verified in read-only startup with %s\n' "$phase" "$shell_path"
    fi

    if (( dry_run )); then
        if (( would_install_zshenv )) && [[ ${ZDOTDIR-$HOME} -ef "$HOME" ]]; then
            printf 'ZDOTDIR after planned installation %s (managed default; user startup hooks may override it)\n' "$target_dir"
            return
        fi
        printf 'ZDOTDIR after planned installation %s (expected with the same early startup file)\n' "${effective:-unverified}"
    fi

    if [[ $rcs == off ]]; then
        printf 'Warning: Early startup disabled RCS, so Zsh may skip its .zprofile and .zshrc.\n' >&2
    elif [[ -n $effective && $effective != "$target_dir" ]]; then
        printf 'Warning: Zsh looks for .zprofile and .zshrc in %s, but the installer targets %s.\n' "$effective" "$target_dir" >&2
    elif [[ -n $effective ]]; then
        return
    fi
    printf 'In the affected Zsh, run %s to check its startup directory and adjust your ZDOTDIR or integrate the files in %s.\n' \
        'print -r -- "${ZDOTDIR-$HOME}"' "$target_dir" >&2
}

if (( macos )); then
    report_macos_zdotdir
fi

if (( change_shell )); then
    if (( dry_run )); then
        printf 'Would set the login shell for %s to /bin/zsh\n' "$current_user"
    else
        sudo chsh -s /bin/zsh "$current_user"
    fi
fi

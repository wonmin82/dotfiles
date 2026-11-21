[[ -o interactive && $OSTYPE == darwin* && -z ${_dotfiles_homebrew_checked-} ]] || return 0
typeset -g _dotfiles_homebrew_checked=1

() {
    local prefix shellenv
    local -a prefixes
    # Match the running shell, including x86_64 shells under Rosetta.
    case "$(/usr/bin/uname -m)" in
        arm64) prefixes=(/opt/homebrew /usr/local) ;;
        x86_64) prefixes=(/usr/local /opt/homebrew) ;;
        *) return 0 ;;
    esac

    for prefix in "${prefixes[@]}"; do
        [[ -f "$prefix/bin/brew" && -x "$prefix/bin/brew" ]] || continue
        if [[ ${HOMEBREW_PREFIX-} != "$prefix" || $(whence -p brew) != "$prefix/bin/brew" ]]; then
            # Ask for the full environment even when the parent already set PATH.
            shellenv=$(PATH="/usr/bin:$PATH" "$prefix/bin/brew" shellenv zsh 2>/dev/null) || continue
            eval "$shellenv" || return
        fi
        # Restore Homebrew's precedence after login startup reorders an inherited PATH.
        typeset -gU path
        path=("$prefix/bin" "$prefix/sbin" "${path[@]}")
        return 0
    done
}

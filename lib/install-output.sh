report_file() {
    local label="[$1]" target="$2" detail="${3-}"
    if (( ${4:-0} )); then
        label="[DRY-RUN] $label"
    fi
    if [[ -n "$detail" ]]; then
        printf '%s %s (%s)\n' "$label" "$target" "$detail"
    else
        printf '%s %s\n' "$label" "$target"
    fi
}

copy_config_file() {
    local source_file="$1" target="$2" destination="$2" action=NEW
    if [[ -d "$target" ]]; then
        destination="$target/${source_file##*/}"
    fi
    if [[ -e "$destination" || -L "$destination" ]]; then
        action=OVERWRITE
    fi
    cp -f "$source_file" "$target" || return
    report_file "$action" "$destination"
}

# shellcheck shell=bash
#
# Shared helpers for HyprServ. Sourced, never executed.

# Absolute path to the installation root (the directory containing lib/ and scripts/).
hs_root() {
    printf '%s' "${HYPRSERV_ROOT:?hs_root: HYPRSERV_ROOT is not set}"
}

# Print a message to stderr, prefixed.
hs_warn() {
    printf 'hyprserv: %s\n' "$*" >&2
}

# Print a message to stderr and exit non-zero.
hs_die() {
    hs_warn "$@"
    exit 1
}

# Strip leading and trailing whitespace from $1.
hs_trim() {
    local s=$1
    s=${s#"${s%%[![:space:]]*}"}
    s=${s%"${s##*[![:space:]]}"}
    printf '%s' "$s"
}

# Registry path, in precedence order:
#   $HYPRSERV_CONFIG        explicit override (tests, one-off runs)
#   $XDG_CONFIG_HOME/...    per-user override
#   /etc/hyprserv/...       system-wide
#   <root>/config/...       bundled default
#
# Not used by the privileged action script — see hs_system_config_file.
hs_config_file() {
    local xdg=${XDG_CONFIG_HOME:-${HOME:-}/.config}

    if [[ -n ${HYPRSERV_CONFIG:-} ]]; then
        printf '%s' "$HYPRSERV_CONFIG"
    elif [[ -r $xdg/hyprserv/services.conf ]]; then
        printf '%s' "$xdg/hyprserv/services.conf"
    elif [[ -r /etc/hyprserv/services.conf ]]; then
        printf '%s' /etc/hyprserv/services.conf
    else
        printf '%s' "$(hs_root)/config/services.conf"
    fi
}

# Registry path for the privileged path. Never resolves into a user-writable
# location, so a compromised or careless $HOME cannot widen what root will act on.
hs_system_config_file() {
    if [[ -r /etc/hyprserv/services.conf ]]; then
        printf '%s' /etc/hyprserv/services.conf
    else
        printf '%s' "$(hs_root)/config/services.conf"
    fi
}

# Populate HS_UNITS (ordered) and the HS_ICON / HS_LABEL / HS_TRACKED maps.
# Safe to call more than once.
hs_load_services() {
    local file=${1:-$(hs_config_file)}
    local line unit icon label tracked

    [[ -r $file ]] || hs_die "cannot read service registry: $file"

    HS_UNITS=()
    declare -gA HS_ICON=() HS_LABEL=() HS_TRACKED=()

    while IFS= read -r line || [[ -n $line ]]; do
        line=$(hs_trim "$line")
        [[ -z $line || $line == '#'* ]] && continue

        IFS='|' read -r unit icon label tracked <<<"$line"
        unit=$(hs_trim "${unit-}")
        [[ -n $unit ]] || continue

        HS_UNITS+=("$unit")
        HS_ICON[$unit]=$(hs_trim "${icon-}")
        HS_LABEL[$unit]=$(hs_trim "${label-}")
        [[ $(hs_trim "${tracked-}") == yes ]] && HS_TRACKED[$unit]=1 || true
    done <"$file"

    (( ${#HS_UNITS[@]} > 0 )) || hs_die "service registry is empty: $file"
}

# True if $1 is defined in the registry. Call hs_load_services first.
hs_is_known_unit() {
    local u
    for u in "${HS_UNITS[@]}"; do
        [[ $u == "$1" ]] && return 0
    done
    return 1
}

# Display text for $1: "<icon> <label>", falling back to the bare unit name.
hs_display_name() {
    local unit=$1 icon=${HS_ICON[$1]-} label=${HS_LABEL[$1]-}
    [[ -n $label ]] || label=$unit
    [[ -n $icon ]] && printf '%s %s' "$icon" "$label" || printf '%s' "$label"
}

# Print one of: active | inactive | missing
hs_unit_state() {
    local unit=$1
    if ! systemctl cat -- "$unit" >/dev/null 2>&1; then
        printf 'missing'
    elif systemctl is-active --quiet -- "$unit" >/dev/null 2>&1; then
        printf 'active'
    else
        printf 'inactive'
    fi
}

# Escape $1 for use inside a JSON string literal.
# Control characters below 0x20 other than \n \r \t are not handled: they
# cannot occur in a service label typed by hand, so the loop isn't worth it.
hs_json_escape() {
    local s=$1
    s=${s//\\/\\\\}       # backslash first, or it double-escapes the others
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\r'/\\r}
    s=${s//$'\t'/\\t}
    printf '%s' "$s"
}

# Emit the Waybar module object. $1 state, $2 tooltip.
# The state is used for both "alt" (icon lookup) and "class" (CSS) — they must agree.
hs_emit_waybar_json() {
    local state=$1 tooltip=$2
    printf '{"alt": "%s", "tooltip": "%s", "class": "%s"}\n' \
        "$state" "$(hs_json_escape "$tooltip")" "$state"
}

# Human-readable description of an action string.
hs_describe_action() {
    case $1 in
        start_all)   printf 'Start all services' ;;
        stop_all)    printf 'Stop all services' ;;
        restart_all) printf 'Restart running services' ;;
        toggle:*)    printf 'Toggle %s' "$(hs_display_name "${1#toggle:}")" ;;
        restart:*)   printf 'Restart %s' "$(hs_display_name "${1#restart:}")" ;;
        *)           printf '%s' "$1" ;;
    esac
}

# Desktop notification for the outcome of an action.
# $1 action string, $2 exit status, $3 captured output.
hs_notify_result() {
    local action=$1 rc=$2 output=$3 what
    command -v notify-send >/dev/null 2>&1 || return 0

    what=$(hs_describe_action "$action")

    if (( rc == 0 )); then
        notify-send --app-name=HyprServ --icon=emblem-default \
            --expire-time=2000 "HyprServ" "$what — done"
    elif (( rc == 126 || rc == 127 )); then
        # pkexec's own codes: authorisation dismissed or not authorised.
        notify-send --app-name=HyprServ --icon=dialog-information \
            --expire-time=2000 "HyprServ" "$what — cancelled"
    else
        notify-send --app-name=HyprServ --icon=dialog-error --urgency=critical \
            "HyprServ" "$what — failed"$'\n'"${output:-exit status $rc}"
    fi
}

# Nudge Waybar to re-poll immediately instead of waiting out its interval.
# Requires "signal": 8 on the module; harmless if not configured.
hs_refresh_waybar() {
    command -v pkill >/dev/null 2>&1 || return 0
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

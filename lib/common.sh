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

# Path to the service registry.
hs_config_file() {
    printf '%s' "${HYPRSERV_CONFIG:-$(hs_root)/config/services.conf}"
}

# Populate HS_UNITS (ordered) and the HS_ICON / HS_LABEL / HS_TRACKED maps.
# Safe to call more than once.
hs_load_services() {
    local file line unit icon label tracked

    file=$(hs_config_file)
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

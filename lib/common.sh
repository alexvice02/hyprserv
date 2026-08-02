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

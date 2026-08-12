#!/usr/bin/env bash
set -euo pipefail
source "$HYPRSERV_ROOT/tests/lib.bash"
source "$HYPRSERV_ROOT/lib/common.sh"

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

make_registry "$tmp/services.conf" <<'EOF'
# comment

alpha | A | Alpha | yes
beta  | B | Beta   | no
EOF

assert_eq "hs_trim strips both ends" "x" "$(hs_trim '   x   ')"

HYPRSERV_CONFIG=$tmp/services.conf hs_load_services
assert_eq "skips comments and blanks" "alpha beta" "${HS_UNITS[*]}"
assert_eq "only tracked units counted" "1" "${#HS_TRACKED[@]}"
assert_eq "display name joins icon and label" "A Alpha" "$(hs_display_name alpha)"
assert_eq "unknown unit falls back to unit name" "gamma" "$(hs_display_name gamma)"

if hs_is_known_unit alpha; then hs_t_ok "known unit accepted"; else hs_t_fail "known unit accepted"; fi
if hs_is_known_unit nope; then hs_t_fail "unknown unit rejected"; else hs_t_ok "unknown unit rejected"; fi

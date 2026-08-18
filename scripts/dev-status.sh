#!/usr/bin/env bash
set -euo pipefail

HYPRSERV_ROOT=${HYPRSERV_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=../lib/common.sh
source "$HYPRSERV_ROOT/lib/common.sh"

hs_load_services

running=0
total=0
missing=0
lines=()

for unit in "${HS_UNITS[@]}"; do
    [[ -n ${HS_TRACKED[$unit]:-} ]] || continue
    case "$(hs_unit_state "$unit")" in
        active)   total=$(( total + 1 )); running=$(( running + 1 ))
                  lines+=("● $(hs_display_name "$unit")") ;;
        inactive) total=$(( total + 1 ))
                  lines+=("○ $(hs_display_name "$unit")") ;;
        missing)  missing=$(( missing + 1 ))
                  lines+=("· $(hs_display_name "$unit") (not installed)") ;;
    esac
done

summary="$running of $total services running"
(( running == total )) && summary="All $total services running"
(( running == 0 ))     && summary="All $total services stopped"

tooltip=$summary
for line in "${lines[@]}"; do
    tooltip+=$'\n'$line
done

if (( total == 0 )); then
    hs_emit_waybar_json stopped "No tracked services installed"
elif (( running == total )); then
    hs_emit_waybar_json running "$tooltip"
elif (( running == 0 )); then
    hs_emit_waybar_json stopped "$tooltip"
else
    hs_emit_waybar_json partial "$tooltip"
fi
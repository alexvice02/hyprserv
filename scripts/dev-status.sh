#!/usr/bin/env bash
set -euo pipefail

HYPRSERV_ROOT=${HYPRSERV_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=../lib/common.sh
source "$HYPRSERV_ROOT/lib/common.sh"

hs_load_services

running=0
total=0

for unit in "${HS_UNITS[@]}"; do
    [[ -n ${HS_TRACKED[$unit]:-} ]] || continue
    total=$(( total + 1 ))
    if systemctl is-active --quiet -- "$unit"; then
        running=$(( running + 1 ))
    fi
done

if (( total == 0 )); then
    hs_emit_waybar_json stopped "No services tracked"
elif (( running == total )); then
    hs_emit_waybar_json running "All dev services running"
elif (( running == 0 )); then
    hs_emit_waybar_json stopped "All dev services stopped"
else
    hs_emit_waybar_json partial "$running of $total services running"
fi
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
    printf '%s\n' '{"alt": "stopped", "tooltip": "No services tracked", "class": "stopped"}'
elif (( running == total )); then
    printf '%s\n' '{"alt": "running", "tooltip": "All dev services running", "class": "running"}'
elif (( running == 0 )); then
    printf '%s\n' '{"alt": "stopped", "tooltip": "All dev services stopped", "class": "stopped"}'
else
    printf '{"alt": "partial", "tooltip": "%s of %s services running", "class": "partial"}\n' \
        "$running" "$total"
fi
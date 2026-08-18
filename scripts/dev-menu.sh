#!/usr/bin/env bash
set -euo pipefail

HYPRSERV_ROOT=${HYPRSERV_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=../lib/common.sh
source "$HYPRSERV_ROOT/lib/common.sh"

hs_load_services

options="⏵ Start all"$'\n'"⏹ Stop all"$'\n'

for unit in "${HS_UNITS[@]}"; do
    case "$(hs_unit_state "$unit")" in
        active)   mark="●" ;;
        inactive) mark="○" ;;
        missing)  mark="·" ;;
    esac
    options+="$(hs_display_name "$unit") ($unit) $mark"$'\n'
done


if command -v wofi >/dev/null 2>&1; then
    choice=$(echo "$options" | wofi --dmenu --prompt "Toggle service:")
elif command -v rofi >/dev/null 2>&1; then
    choice=$(echo "$options" | rofi -dmenu -p "Toggle service:")
else
    hs_die "wofi or rofi is required"
fi


[[ -z "$choice" ]] && exit 0


if [[ "$choice" == "⏵ Start all" ]]; then
    action="start_all"
elif [[ "$choice" == "⏹ Stop all" ]]; then
    action="stop_all"
else
    service=$(echo "$choice" | grep -oP '\(([^)]+)\)' | tr -d '()')
    action="toggle:$service"
fi


pkexec "$HYPRSERV_ROOT/scripts/dev-action.sh" "$action"
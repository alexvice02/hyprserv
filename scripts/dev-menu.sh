#!/usr/bin/env bash
set -euo pipefail

HYPRSERV_ROOT=${HYPRSERV_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=../lib/common.sh
source "$HYPRSERV_ROOT/lib/common.sh"

hs_load_services

hs_pick() {
    local prompt=$1
    if command -v wofi >/dev/null 2>&1; then
        wofi --dmenu --prompt "$prompt"
    elif command -v rofi >/dev/null 2>&1; then
        rofi -dmenu -p "$prompt"
    else
        hs_die "wofi or rofi is required"
    fi
}

options="⏵ Start all"$'\n'"⏹ Stop all"$'\n'"⟳ Restart…"$'\n'

for unit in "${HS_UNITS[@]}"; do
    case "$(hs_unit_state "$unit")" in
        active)   mark="●" ;;
        inactive) mark="○" ;;
        missing)  mark="·" ;;
    esac
    options+="$(hs_display_name "$unit") ($unit) $mark"$'\n'
done


choice=$(echo "$options" | hs_pick "Toggle service:")


[[ -z "$choice" ]] && exit 0


if [[ "$choice" == "⏵ Start all" ]]; then
    action="start_all"
elif [[ "$choice" == "⏹ Stop all" ]]; then
    action="stop_all"
elif [[ "$choice" == "⟳ Restart…" ]]; then
    restart_options="⟳ Restart all running"$'\n'
    for unit in "${HS_UNITS[@]}"; do
        [[ $(hs_unit_state "$unit") == active ]] || continue
        restart_options+="$(hs_display_name "$unit") ($unit)"$'\n'
    done

    pick=$(printf '%s' "$restart_options" | hs_pick "Restart service:")
    [[ -z "$pick" ]] && exit 0

    if [[ "$pick" == "⟳ Restart all running" ]]; then
        action="restart_all"
    else
        unit=$(grep -oP '\(([^)]+)\)' <<<"$pick" | tr -d '()')
        action="restart:$unit"
    fi
else
    service=$(echo "$choice" | grep -oP '\(([^)]+)\)' | tr -d '()')
    action="toggle:$service"
fi


rc=0
output=$(pkexec "$HYPRSERV_ROOT/scripts/dev-action.sh" "$action" 2>&1) || rc=$?

hs_notify_result "$action" "$rc" "$output"
hs_refresh_waybar

exit "$rc"
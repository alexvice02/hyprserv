#!/usr/bin/env bash
set -euo pipefail

HYPRSERV_ROOT=${HYPRSERV_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=../lib/common.sh
source "$HYPRSERV_ROOT/lib/common.sh"

hs_load_services "$(hs_system_config_file)"

(( $# == 1 )) || hs_die "expected exactly one action argument, got $#"

case "$1" in
    start_all)
        for unit in "${HS_UNITS[@]}"; do
            systemctl start -- "$unit" || hs_warn "failed to start: $unit"
        done
        ;;
    stop_all)
        for unit in "${HS_UNITS[@]}"; do
            systemctl stop -- "$unit" || hs_warn "failed to stop: $unit"
        done
        ;;
    toggle:*)
        unit=${1#toggle:}
        hs_is_known_unit "$unit" \
            || hs_die "refusing to act on unit outside the registry: $unit"
        if systemctl is-active --quiet -- "$unit"; then
            systemctl stop -- "$unit"
        else
            systemctl start -- "$unit"
        fi
        ;;
    restart:*)
        unit=${1#restart:}
        hs_is_known_unit "$unit" \
            || hs_die "refusing to act on unit outside the registry: $unit"
        systemctl restart -- "$unit"
        ;;
    restart_all)
        for unit in "${HS_UNITS[@]}"; do
            [[ $(hs_unit_state "$unit") == active ]] || continue
            systemctl restart -- "$unit" || hs_warn "failed to restart: $unit"
        done
        ;;
    *)
        hs_die "unknown command: $1"
        ;;
esac

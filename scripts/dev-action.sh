#!/usr/bin/env bash
set -euo pipefail

HYPRSERV_ROOT=${HYPRSERV_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck source=../lib/common.sh
source "$HYPRSERV_ROOT/lib/common.sh"

services=(postgresql httpd docker php memcached elasticsearch nginx redis mysql mongod rabbitmq-server mariadb)

case "${1:-}" in
    start_all)
        for s in "${services[@]}"; do
            systemctl start -- "$s" || echo "failed to start: $s" >&2
        done
        ;;
    stop_all)
        for s in "${services[@]}"; do
            systemctl stop -- "$s" || echo "failed to stop: $s" >&2
        done
        ;;
    toggle:*)
        svc="${1#toggle:}"
        if systemctl is-active --quiet "$svc"; then
            systemctl stop "$svc"
        else
            systemctl start "$svc"
        fi
        ;;
    *)
        hs_die "unknown command: ${1:-<none>}"
        ;;
esac

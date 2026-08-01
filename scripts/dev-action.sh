#!/usr/bin/env bash
set -euo pipefail

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
        echo "❌ Unknown command: ${1:-}"
        exit 1
        ;;
esac

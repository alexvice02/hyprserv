#!/bin/bash

services=(postgresql httpd docker php memcached elasticsearch nginx redis mysql mongod rabbitmq-server mariadb)

case "$1" in
    start_all)
        for s in "${services[@]}"; do
            systemctl start "$s"
        done
        ;;
    stop_all)
        for s in "${services[@]}"; do
            systemctl stop "$s"
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
        echo "❌ Unknown command: $1"
        exit 1
        ;;
esac

#!/bin/bash

services=(postgresql httpd docker php memcached elasticsearch nginx redis mysql mongod rabbitmq-server mariadb)

declare -A labels=(
    [postgresql]=" PostgreSQL"
    [httpd]=" Apache"
    [docker]=" Docker"
    [php]=" PHP"
    [memcached]="󰍛 Memcached"
    [elasticsearch]=" Elasticsearch"
    [nginx]=" Nginx"
    [redis]=" Redis"
    [mysql]=" MySQL"
    [mongod]=" MongoDB"
    [rabbitmq-server]=" RabbitMQ"
    [mariadb]=" MariaDB"
)


options="⏵ Start all"$'\n'"⏹ Stop all"$'\n'

for service in "${services[@]}"; do
    status=$(systemctl is-active --quiet "$service" && echo "●" || echo "○")
    label="${labels[$service]:-$service}"
    options+="$label ($service) $status"$'\n'
done


if command -v wofi >/dev/null 2>&1; then
    choice=$(echo "$options" | wofi --dmenu --prompt "Toggle service:")
elif command -v rofi >/dev/null 2>&1; then
    choice=$(echo "$options" | rofi -dmenu -p "Toggle service:")
else
    echo "❗ wofi or rofi is required"
    exit 1
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


pkexec /path/to/scripts/dev-action.sh "$action"
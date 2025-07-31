# Services list
services=(postgresql httpd docker php memcached elasticsearch nginx redis mysql mongod rabbitmq-server mariadb)

# Labels and Icons
declare -A labels=(
    [postgresql]=" PostgreSQL"
    [httpd]=" Apache"
    [docker]=" Docker"
    [php]=" PHP"
    [memcached]="󰍛 Memcached"
    [elasticsearch]="  Elasticsearch"
    [nginx]=" Nginx"
    [redis]=" Redis"
    [mysql]=" MySQL"
    [mongod]=" MongoDB"
    [rabbitmq-server]=" RabbitMQ"
    [mariadb]=" MariaDB"
)

# Build list of services with statuses
options="⏵ Start all"$'\n'"⏹ Stop all"$'\n'
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        status="●"
    else
        status="○"
    fi

    label="${labels[$service]:-$service}"
    options+="$label ($service) $status"$'\n'
done

# User choice
if command -v rofi >/dev/null 2>&1; then
    if rofi -v | grep -q "wayland"; then
        choice=$(echo "$options" | rofi -show -dmenu -prompt "Toggle dev service:")
    else
        choice=$(echo "$options" | rofi -dmenu -p "Toggle dev service:")
    fi
elif command -v wofi >/dev/null 2>&1; then
    choice=$(echo "$options" | wofi --dmenu --prompt "Toggle dev service:")
else
    echo "Neither rofi nor wofi is installed."
    exit 1
fi
[[ -z "$choice" ]] && exit 0

# Handle start all / stop all
if [[ "$choice" == "⏵ Start all" ]]; then
    for service in "${services[@]}"; do
        systemctl start "$service"
    done
    exit 0
elif [[ "$choice" == "⏹ Stop all" ]]; then
    for service in "${services[@]}"; do
        systemctl stop "$service"
    done
    exit 0
fi

# Get service name from choice
service=$(echo "$choice" | grep -oP '\(([^)]+)\)' | tr -d '()')

# Toggle service
if systemctl is-active --quiet "$service"; then
    systemctl stop "$service"
else
    systemctl start "$service"
fi
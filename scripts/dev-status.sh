services=(postgresql httpd docker.service)

running=0

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        ((running++))
    fi
done

if (( running == ${#services[@]} )); then
    echo '{"alt": "running", "tooltip": "All dev services running", "class": "running"}'
elif (( running == 0 )); then
    echo '{"alt": "stopped", "tooltip": "All dev services stopped", "class": "stopped"}'
else
    echo '{"alt": "partial", "tooltip": "'"$running of ${#services[@]} services running"'", "class": "partial"}'
fi
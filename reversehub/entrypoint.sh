#!/bin/sh
set -e

PORT="${RH_PORT:-8080}"

echo "==> Generating nginx proxy locations from services.json..."
/generate-locations.sh

# Patch listen directive at runtime
sed -i "s/__RH_PORT__/${PORT}/" /etc/nginx/nginx.conf

echo "==> Starting nginx on 127.0.0.1:${PORT}..."
nginx -g "daemon off;" &
NGINX_PID=$!

echo "==> Watching services.json for changes..."
inotifyd - /usr/share/nginx/html/services.json:cwy | while read -r event; do
    echo "==> services.json changed, regenerating & reloading..."
    /generate-locations.sh
    nginx -s reload
done &

wait $NGINX_PID

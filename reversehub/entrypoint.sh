#!/bin/sh
set -e

echo "==> Generating nginx proxy locations from services.json..."
/generate-locations.sh

echo "==> Starting nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

echo "==> Watching services.json for changes (inotifyd)..."
# inotifyd calls the script when services.json is modified/moved-to
inotifyd - /usr/share/nginx/html/services.json:cwy | while read -r event; do
    echo "==> services.json changed ($event), regenerating & reloading nginx..."
    /generate-locations.sh
    nginx -s reload
done &

wait $NGINX_PID

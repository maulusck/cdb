#!/bin/sh
# Generates /etc/nginx/locations.d/*.conf from /usr/share/nginx/html/services.json
set -e

SERVICES_FILE="/usr/share/nginx/html/services.json"
OUT_DIR="/etc/nginx/locations.d"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.conf

count=$(jq 'length' "$SERVICES_FILE")
i=0
while [ "$i" -lt "$count" ]; do
    name=$(jq -r ".[$i].name" "$SERVICES_FILE")
    port=$(jq -r ".[$i].port" "$SERVICES_FILE")
    proxy_path=$(jq -r ".[$i].proxy_path" "$SERVICES_FILE")
    upstream_path=$(jq -r ".[$i].upstream_path" "$SERVICES_FILE")

    fname=$(echo "$name" | tr '[:upper:] ' '[:lower:]_')

    cat > "$OUT_DIR/${fname}.conf" <<NGINX
location ${proxy_path} {
    proxy_pass http://127.0.0.1:${port}${upstream_path};
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_read_timeout 86400;
    proxy_buffering off;
}
NGINX

    echo "  → ${proxy_path} → 127.0.0.1:${port}${upstream_path}"
    i=$((i + 1))
done

echo "Generated $count location blocks."

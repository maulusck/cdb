#!/bin/sh
# Generates /etc/nginx/locations.d/*.conf from /usr/share/nginx/html/services.json
set -e

SERVICES_FILE="/usr/share/nginx/html/services.json"
OUT_DIR="/etc/nginx/locations.d"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.conf

# Requires jq (installed in image)
count=$(jq 'length' "$SERVICES_FILE")
i=0
while [ "$i" -lt "$count" ]; do
    name=$(jq -r ".[$i].name" "$SERVICES_FILE")
    port=$(jq -r ".[$i].port" "$SERVICES_FILE")
    path=$(jq -r ".[$i].path" "$SERVICES_FILE")

    # Sanitize name for filename
    fname=$(echo "$name" | tr '[:upper:] ' '[:lower:]_')

    cat > "$OUT_DIR/${fname}.conf" <<EOF
location ${path} {
    proxy_pass http://127.0.0.1:${port}${path};
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    # WebSocket support
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;

    proxy_read_timeout 86400;
    proxy_buffering off;
}
EOF

    echo "  → ${path} → localhost:${port}"
    i=$((i + 1))
done

echo "Generated $count location blocks."

#!/bin/sh
set -e

PORT="${RH_PORT:-8080}"
SERVICES="/usr/share/nginx/html/services.json"
OUT="/etc/nginx/locations.d"

echo "==> generating proxy locations from services.json"
mkdir -p "$OUT"
rm -f "$OUT"/*.conf

jq -c '.[]' "$SERVICES" | while read -r svc; do
    name=$(echo "$svc"     | jq -r '.name')
    upstream=$(echo "$svc" | jq -r '.upstream')
    upath=$(echo "$svc"    | jq -r '.upstream_path')
    ppath=$(echo "$svc"    | jq -r '.proxy_path')
    fname=$(echo "$name" | tr '[:upper:] ' '[:lower:]_')

    cat > "$OUT/${fname}.conf" <<NGINX
location ${ppath} {
    proxy_pass http://${upstream}${upath};
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
    echo "  -> ${ppath} -> ${upstream}${upath}"
done

sed -i "s/__RH_PORT__/${PORT}/" /etc/nginx/nginx.conf

echo "==> nginx on 0.0.0.0:${PORT}"
exec nginx -g "daemon off;"

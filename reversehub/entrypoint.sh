#!/bin/sh
set -e

PORT="${RH_PORT:-8080}"
SERVICES="/usr/share/nginx/html/services.json"
LOC="/etc/nginx/locations.d"
SRV="/etc/nginx/servers.d"

# Shared proxy directives (escaped for the heredocs below)
proxy_block() {
    cat <<NGINX
        proxy_pass http://${1}${2};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_read_timeout 86400;
        proxy_buffering off;
NGINX
}

echo "==> generating proxy config from services.json"
mkdir -p "$LOC" "$SRV"
rm -f "$LOC"/*.conf "$SRV"/*.conf

jq -c '.[]' "$SERVICES" | while read -r svc; do
    name=$(echo "$svc"     | jq -r '.name')
    mode=$(echo "$svc"     | jq -r '.mode // "path"')
    upstream=$(echo "$svc" | jq -r '.upstream')
    upath=$(echo "$svc"    | jq -r '.upstream_path // "/"')
    fname=$(echo "$name" | tr '[:upper:] ' '[:lower:]_')

    if [ "$mode" = "host" ]; then
        domain=$(echo "$svc" | jq -r '.domain')
        {
            echo "server {"
            echo "    listen ${PORT};"
            echo "    server_name ${domain};"
            echo "    location / {"
            proxy_block "$upstream" "$upath"
            echo "    }"
            echo "}"
        } > "$SRV/${fname}.conf"
        echo "  -> host  ${domain} -> ${upstream}${upath}"
    else
        ppath=$(echo "$svc" | jq -r '.proxy_path')
        {
            echo "location ${ppath} {"
            proxy_block "$upstream" "$upath"
            echo "}"
        } > "$LOC/${fname}.conf"
        echo "  -> path  ${ppath} -> ${upstream}${upath}"
    fi
done

sed -i "s/__RH_PORT__/${PORT}/" /etc/nginx/nginx.conf

echo "==> nginx on 0.0.0.0:${PORT}"
exec nginx -g "daemon off;"

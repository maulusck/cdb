#!/bin/sh
set -e

# get data
. ./.env

podman run -p $WEBPORT:80 -v $WEBROOT:/var/www/localhost -v $CONFIG:/etc/lighttpd $REPO/$IMAGE

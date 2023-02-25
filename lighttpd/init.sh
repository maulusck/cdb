!/bin/sh
set -e

# get data
. ./.env

podman run -v $WEBROOT:/var/www/localhost $REPO/$IMAGE

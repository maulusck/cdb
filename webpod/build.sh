#!/bin/sh

POD="webpod-1"
NGINX_CONTAINER="nginx-webpod-1"
APACHE_CONTAINER="apache-webpod-1"
ICECAST_CONTAINER="icecast-webpod-1"

# build nginx
podman build -f Dockerfile.nginx -t $NGINX_CONTAINER .

# build apache2
podman build -f Dockerfile.apache -t $APACHE_CONTAINER .

# build icecast
podman build -f Dockerfile.icecast -t $ICECAST_CONTAINER .

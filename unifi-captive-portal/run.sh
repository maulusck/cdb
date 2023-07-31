#!/bin/sh

# since we are running rootless podman, 443 interface is binded on 65443 host port,
# a proxy [nginx is fine] will be needed to use 443 directly

# entrypoint is startup script /etc/init.d/unifi, so it's needed to provide a command [start, stop...]

REPO="localhost"
IMAGE="unifi-test"

podman run -p 65443:443 \
	-p 6789:6789/tcp \
	-p 8080:8080/tcp \
	-p 8443:8443/tcp \
	-p 27117:27117/tcp \
	-p 1900:1900/udp \
	-p 3478:3478/udp \
	-p 5514:5514/udp \
	-p 5656-5699:5656-5699/udp \
	-p 10001:10001/udp \
	${@} $REPO/$IMAGE

# or set up 443 as unprivileged port, and run this
#podman run --network host ${@} $REPO/$IMAGE

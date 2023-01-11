#!/bin/sh
# container settings
REPO="localhost"
IMAGE="streamlink-otg"
TAG="latest"
NAME="recorder-oneshot"
# where you want to bind /recordings
REC_DIR="/opt/recordings/"
# cli args
OPTS="${@}"

podman run --rm -it --name $NAME -v $REC_DIR:/recordings $REPO/$IMAGE:$TAG $OPTS

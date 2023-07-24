#!/bin/sh

REPO="localhost"
IMAGE="unifi-captive-portal"

podman build -t $IMAGE .

#!/bin/bash

# Java 8
curl -fsSL "https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public" | gpg --dearmor --yes -o /usr/share/keyrings/adoptopenjdk-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptopenjdk-archive-keyring.gpg] https://adoptopenjdk.jfrog.io/adoptopenjdk/deb bullseye main" | tee /etc/apt/sources.list.d/adoptopenjdk.list
apt update && apt install -y adoptopenjdk-8-hotspot

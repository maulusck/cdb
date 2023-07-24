#!/bin/bash

# MongoDB 3.6
wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add -
echo "deb https://repo.mongodb.org/apt/debian stretch/mongodb-org/3.6 main" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list

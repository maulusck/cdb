#!/bin/sh
set -e
echo "Starting Unifi captive portal..."
/etc/init.d/unifi start
echo "Reading logs. Press Ctrl+C to exit."
tail -f /var/log/unifi/*.log

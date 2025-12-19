#!/bin/bash

# Find the SSH port number
SSH_PORT=$(ss -tnl | grep LISTEN | awk '$4 ~ /:22$/ {print 22; exit}' || echo 22)

echo "------------------------------------------------------"
if [ -n "$CONNECT_TTY" ]; then
    echo "You are connecting via "
fi

# Use 'ss' to find the established connection to the SSH port and extract the remote IP
# The 'ss' command output format might vary slightly, but this targets an established connection
# to the local SSH port (usually 22).

CLIENT_IP=$(ss -tnp | grep ":$SSH_PORT" | grep ESTAB | awk '{print $5}' | cut -d: -f1 | head -n 1)

if [ -n "$CLIENT_IP" ]; then
    echo "Client IP address: $CLIENT_IP"
else
    echo "Client IP information not found via 'ss' command."
fi
echo "------------------------------------------------------"


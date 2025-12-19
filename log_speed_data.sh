#!/bin/bash

# Color Definitions (ensure these are present in your .bashrc too for consistency)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

LOG_FILE="/var/log/net_speed.log"

# Get current date/time
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Run speedtest-cli and extract ping, download, upload
if command -v speedtest-cli &> /dev/null; then
    # Extracts numerical values for Ping, Download, Upload
    SPEED_DATA=$(speedtest-cli --simple | awk '/Ping:|Download:|Upload:/ {print $2}')
    
    # Check if data was captured successfully
    if [ -n "$SPEED_DATA" ]; then
        # Format the output into a single line: TIMESTAMP Ping Download Upload
        echo "$TIMESTAMP $SPEED_DATA" | tr '\n' ' ' >> "$LOG_FILE"
        echo "" >> "$LOG_FILE" # Add a final newline character
    else
        echo "Error: speedtest-cli data format issue."
    fi
else
    echo "Error: speedtest-cli is not installed."
fi

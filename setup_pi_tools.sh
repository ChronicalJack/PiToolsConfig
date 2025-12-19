#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Alias Definitions ---
alias ll='ls -lah'

# --- Function Definitions ---

# Custom function to clear the terminal and reload .bashrc
clean() {
    clear
    source ~/.bashrc
    echo "Terminal cleared and .bashrc reloaded."
}

# Custom diagnostics function with colors and spacing
diagnostics() {
    echo -e "${BLUE}--- RASPBERRY PI DIAGNOSTICS ---${NC}"
    echo "Date: $(date)"
    
    echo -e "\n${YELLOW}[CPU Temperature]${NC}"
    TEMP=$(vcgencmd measure_temp | cut -c 6-9) 
    echo "${TEMP}°C"
    
    echo -e "\n${YELLOW}[Disk Usage]${NC}"
    df -h / | awk 'NR==2 {print "Total: "$2", Used: "$3", Free: "$4" ("$5")"}'
    
    echo -e "\n${YELLOW}[WiFi Signal]${NC}"
    iwconfig wlan0 | grep -iE "ESSID|Quality|Signal level" | sed 's/Link Quality/\nLink Quality/' | sed "s/Signal level/\nSignal level/"

    echo -e "\n${YELLOW}[WiFi Speed Test] - This may take a moment...${NC}"
    if command -v speedtest-cli &> /dev/null; then
        speedtest-cli --simple
    else
        echo -e "${RED}Error: speedtest-cli is not installed. Run 'sudo apt install speedtest-cli' first.${NC}"
    fi
    echo -e "${BLUE}--------------------------------${NC}"
}

# Function to calculate averages from the log file with color coding
net_averages() {
    LOG_FILE="/var/log/net_speed.log"
    if [ ! -f "$LOG_FILE" ] || [ ! -s "$LOG_FILE" ]; then
        echo -e "${RED}Log file is empty or does not exist.${NC}"
        return 1
    fi

    echo -e "${BLUE}--- Network Speed Averages ---${NC}"
    awk -v VAR_RED="$RED" -v VAR_GREEN="$GREEN" -v VAR_NC="$NC" '{sum_p+=$2; sum_d+=$3; sum_u+=$4; count++} END {
        if (count > 0) {
            printf "Total Runs: %d\n", count
            avg_p=sum_p/count; color_p=VAR_GREEN; if (avg_p > 60) color_p=VAR_RED;
            printf "Avg Ping:   %s%.2f ms%s\n", color_p, avg_p, VAR_NC
            avg_d=sum_d/count; color_d=VAR_GREEN; if (avg_d < 20) color_d=VAR_RED;
            printf "Avg Download: %s%.2f Mbit/s%s\n", color_d, avg_d, VAR_NC
            avg_u=sum_u/count; color_u=VAR_GREEN; if (avg_u < 10) color_u=VAR_RED;
            printf "Avg Upload: %s%.2f Mbit/s%s\n", color_u, avg_u, VAR_NC
        }
    }' "$LOG_FILE"
    echo -e "${BLUE}------------------------------${NC}"
}

# Interactive menu function for custom bash tools (single run version)
tools() {
    clear
    echo -e "${BLUE}---------------------------------${NC}"
    echo -e "${YELLOW} RASPBERRY PI TOOLS MENU${NC}"
    echo -e "${BLUE}---------------------------------${NC}"
    echo " 1. Diagnostics (Speed/Stats)"
    echo " 2. Clean (Clear screen & reload)"
    echo " 3. List Files (Detailed 'll')"
    echo " 4. Edit Config (~/.bashrc)"
    echo " 5. Network Averages"
    echo -e "${RED} 6. Exit Menu${NC}"
    echo -e "${BLUE}---------------------------------${NC}"
    read -p "Enter your choice [1-6]: " choice
    echo ""

    case "$choice" in
        1) diagnostics ;;
        2) clean ;;
        3) ll ;;
        4) nano ~/.bashrc ;;
        5) net_averages ;;
        6) echo "Exiting Tools Menu." ;;
        *) echo -e "${RED}Invalid option $choice. No action taken.${NC}" ;;
    esac
}

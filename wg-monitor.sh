#!/bin/bash

# Configuration
SERVER_IP="192.168.60.3"        # IP address of the server
INTERFACE="wg0"                # Wireguard interface
PING_COUNT=3                   # Number of ping attempts
PING_TIMEOUT=5                 # Timeout for each ping (in seconds)
CHECK_INTERVAL=60              # Check interval in seconds
LOG_FILE="/var/log/wg-monitor.log"  # Log file

# Function for logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Check if the script is running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with root privileges."
    exit 1
fi

log_message "Wireguard monitor started. Monitoring $SERVER_IP over interface $INTERFACE"

while true; do
    # Check if the server is reachable
    if ping -c $PING_COUNT -W $PING_TIMEOUT $SERVER_IP > /dev/null 2>&1; then
        log_message "Server $SERVER_IP is reachable."
    else
        log_message "Server $SERVER_IP is not reachable. Restarting Wireguard connection..."
        
        # Restart Wireguard connection
        log_message "Shutting down Wireguard interface $INTERFACE..."
        wg-quick down $INTERFACE
        
        # Short pause
        sleep 2
        
        log_message "Starting Wireguard interface $INTERFACE..."
        wg-quick up $INTERFACE
        
        # Wait up to 10 seconds for the connection to be reestablished
        for i in {1..10}; do
            sleep 1
            if ping -c 1 -W 1 $SERVER_IP > /dev/null 2>&1; then
                log_message "Connection restored."
                break
            fi
            if [ $i -eq 10 ]; then
                log_message "Connection could not be restored."
            fi
        done
    fi
    
    # Wait for the next check interval
    sleep $CHECK_INTERVAL
done

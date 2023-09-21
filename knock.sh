#!/bin/bash

KNOCK_SEQUENCE="1000 2000 3000"
PORT_TO_OPEN="22"
TIMEOUT=30
declare -a knocks

# Function to open the port
open_port() {
    iptables -A INPUT -p tcp --dport $PORT_TO_OPEN -j ACCEPT
    echo "Port $PORT_TO_OPEN is now open."
}

# Function to close the port
close_port() {
    iptables -D INPUT -p tcp --dport $PORT_TO_OPEN -j ACCEPT
    echo "Port $PORT_TO_OPEN is now closed."
}

# Function to handle the timeout
timeout_handler() {
    echo "Timeout reached. Resetting knocks."
    knocks=()
}

# Main loop
while true; do
    read -p "Enter the next knock: " knock
    knocks+=("$knock")
    
    # Check if the knocks match the sequence
    if [ "${knocks[@]}" = "$KNOCK_SEQUENCE" ]; then
        open_port
        break
    elif [ ${#knocks[@]} -ge ${#KNOCK_SEQUENCE} ]; then
        timeout_handler
    fi
done

# Wait for the timeout and close the port
sleep $TIMEOUT
close_port

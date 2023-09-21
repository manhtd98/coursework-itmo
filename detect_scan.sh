#!/bin/bash

# Network interface to monitor
INTERFACE="eth0"

# Log file to store detected scans
LOG_FILE="/var/log/port_scan.log"

# Number of connection attempts within the time window to consider as a scan
SCAN_THRESHOLD=10

# Time window to analyze connection attempts (in seconds)
SCAN_WINDOW=60

# Function to block an IP address using iptables
block_ip() {
    local ip=$1
    iptables -A INPUT -s $ip -j DROP
    echo "Blocked IP $ip due to port scan."
}

# Function to detect port scans
detect_port_scans() {
    tcpdump -i $INTERFACE -n -tttt 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0' |
    awk -v threshold=$SCAN_THRESHOLD -v window=$SCAN_WINDOW -v logfile=$LOG_FILE '
    {
        now = systime();
        if (now - lasttime > window) {
            delete ips;
            lasttime = now;
        }
        ips[$3]++;
        for (ip in ips) {
            if (ips[ip] >= threshold) {
                print "Detected port scan from", ip, "at", $1 >> logfile;
                block_ip(ip);
                delete ips[ip];
            }
        }
    }'
}

# Main loop
while true; do
    detect_port_scans
done

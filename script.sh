#!/bin/bash
<<doc
Name: Mashak Nadaf
Date:
Title:
Sample I/P:
Sample O/P:
doc



CPU_WARNING=80        # CPU usage warning threshold (%)
MEM_WARNING=80        # Memory usage warning threshold (%)
DISK_WARNING=80       # Disk usage warning threshold (%)
LOG_FILE="/var/log/system_health.log"

get_cpu_usage() {
    top -b -n 1 | grep 'Cpu(s)' | awk '{print $2 + $4}'
}

get_mem_usage() {
    free -m | awk '/Mem:/ {print $3 / $2 * 100}'
}

get_disk_usage() {
    df -h / | awk '/\// {print $5}' | sed 's/%//g'
}

check_network() {
    ping -c 1 8.8.8.8 &> /dev/null
    if [[ $? -eq 0 ]]; then
        echo "Network: OK"
    else
        echo "Network: ERROR"
    fi
}

log_status() {
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    cpu_usage=$(get_cpu_usage)
    mem_usage=$(get_mem_usage)
    disk_usage=$(get_disk_usage)
    network_status=$(check_network)

    echo "$timestamp CPU: $cpu_usage% Memory: $mem_usage% Disk: $disk_usage% Network: $network_status" >> "$LOG_FILE"

    if [[ $cpu_usage -ge $CPU_WARNING ]]; then
        echo "WARNING: CPU usage is high ($cpu_usage%)"
    fi

    if [[ $mem_usage -ge $MEM_WARNING ]]; then
        echo "WARNING: Memory usage is high ($mem_usage%)"
    fi

    if [[ $disk_usage -ge $DISK_WARNING ]]; then
        echo "WARNING: Disk space is low ($disk_usage%)"
    fi
}

case "$1" in
    "start")
        while true; do
            log_status
            sleep 60
        done &
        echo "System health monitoring started."
        ;;
    "stop")
        pkill -f "$0"
        echo "System health monitoring stopped."
        ;;
    "status")
        if ps aux | grep "$0" | grep -v grep > /dev/null 2>&1; then
            echo "System health monitoring is running."
        else
            echo "System health monitoring is not running."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac


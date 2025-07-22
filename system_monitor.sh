#!/bin/bash

# Initial Settings
refresh_rate=3
log_file="anomaly.log"
metrics="ALL"

# Colors
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
NC="\e[0m"

# Function to draw usage bar
draw_bar() {
    local usage=$1
    local label=$2
    local color

    if (( usage < 50 )); then
        color=$GREEN
    elif (( usage < 80 )); then
        color=$YELLOW
    else
        color=$RED
        echo "$(date): High $label usage at $usage%" >> "$log_file"
    fi

    bar=$(printf "%-${usage}s" "#" | tr ' ' '#')
    printf "%-10s: ${color}%-50s ${usage}%%${NC}\n" "$label" "$bar"
}

# Function to get CPU usage
get_cpu_usage() {
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    echo "${cpu%.*}"
}

# Function to get memory usage
get_mem_usage() {
    read total used <<< $(free | awk '/Mem:/ {print $2, $3}')
    echo $(( used * 100 / total ))
}

# Function to get disk usage (/ partition)
get_disk_usage() {
    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "$usage"
}

# Function to get network usage
get_net_usage() {
    rx1=$(cat /sys/class/net/*/statistics/rx_bytes | paste -sd+ - | bc)
    tx1=$(cat /sys/class/net/*/statistics/tx_bytes | paste -sd+ - | bc)
    sleep 1
    rx2=$(cat /sys/class/net/*/statistics/rx_bytes | paste -sd+ - | bc)
    tx2=$(cat /sys/class/net/*/statistics/tx_bytes | paste -sd+ - | bc)

    rx_kb=$(( (rx2 - rx1) / 1024 ))
    tx_kb=$(( (tx2 - tx1) / 1024 ))
    echo "↓ ${rx_kb}KB/s | ↑ ${tx_kb}KB/s"
}

# Function to handle keypresses
handle_keypress() {
    read -rsn1 -t 0.1 key
    case "$key" in
        r)
            echo -n "Enter new refresh rate (seconds): "
            read new_rate
            if [[ "$new_rate" =~ ^[0-9]+$ ]]; then
                refresh_rate=$new_rate
            fi
            ;;
        f)
            echo -n "Filter (CPU/MEM/DISK/NET/ALL): "
            read new_filter
            metrics=${new_filter^^}
            ;;
        q)
            echo -e "\nExiting..."
            exit 0
            ;;
    esac
}

# Main Loop
while true; do
    clear
    echo -e "\e[1mSystem Health Monitor\e[0m (Refresh: ${refresh_rate}s | Press r:rate f:filter q:quit)"
    echo "--------------------------------------------------"

    if [[ $metrics == "CPU" || $metrics == "ALL" ]]; then
        draw_bar "$(get_cpu_usage)" "CPU"
    fi
    if [[ $metrics == "MEM" || $metrics == "ALL" ]]; then
        draw_bar "$(get_mem_usage)" "Memory"
    fi
    if [[ $metrics == "DISK" || $metrics == "ALL" ]]; then
        draw_bar "$(get_disk_usage)" "Disk"
    fi
    if [[ $metrics == "NET" || $metrics == "ALL" ]]; then
        echo -e "Network    : $(get_net_usage)"
    fi

    for ((i = 0; i < refresh_rate * 10; i++)); do
        handle_keypress
        sleep 0.1
    done
done

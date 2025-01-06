#!/bin/bash

# Set the threshold for CPU usage
CPU_THRESHOLD=80

# Function to check CPU usage
check_cpu_usage() {
    # Get the CPU idle percentage from mpstat and calculate the used percentage
    CPU_IDLE=$(mpstat 1 1 | awk '/^Average:/ { print $12 }')
    CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)

    echo "Current CPU usage: $CPU_USAGE%"

    # Compare the current CPU usage with the threshold
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "CPU usage is above $CPU_THRESHOLD%, restarting Laravel service..."
        sudo systemctl restart laravel.service
    else
        echo "CPU usage is below $CPU_THRESHOLD%, no action taken."
    fi
}

# Infinite loop to continuously monitor CPU usage
while true; do
    check_cpu_usage
    sleep 60
done

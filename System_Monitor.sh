#!/bin/bash

LOG_FILE="system_monitor.log"
MONITOR_DURATION=3600  # Default monitoring duration (1 hour)

function display_menu() {
    echo "System Monitoring Menu:"
    echo "1. Check CPU Usage"
    echo "2. Check Memory Usage"
    echo "3. Check Disk Space"
    echo "4. View Log File"
    echo "5. Continuous Monitoring"
    echo "6. Change Monitoring Duration"
    echo "7. Exit"
}

# Updated functions to get resource usage
function get_cpu_usage() {
    top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%.1f%%\n", 100 - v }'
}

function get_memory_usage() {
    free -m | awk 'NR==2{printf "%.2f%%\n", $3*100/$2 }'
}

function get_disk_usage() {
    df -h | awk '$NF=="/"{printf "%s\n", $5}'
}

# Function to view log file contents
function view_log_file() {
    if [ -f "$LOG_FILE" ]; then  # Check if log file exists
        less "$LOG_FILE"  # Open log file with "less" (allows scrolling)
    else
        echo "Log file not found."
    fi
}

# Function for continuous monitoring
function monitor_resources() {
    end=$((SECONDS+$MONITOR_DURATION))

    printf "Time\t\tMemory\t\tDisk\t\tCPU\n"  # Header

    while [ $SECONDS -lt $end ]; do
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        MEMORY=$(get_memory_usage)
        DISK=$(get_disk_usage)
        CPU=$(get_cpu_usage)
        echo "$timestamp\t$MEMORY\t$DISK\t$CPU"
        sleep 5
    done
}

# Function to change monitoring duration
function change_duration() {
    read -p "Enter new monitoring duration (in seconds): " new_duration
    if [[ $new_duration =~ ^[0-9]+$ ]]; then  # Check if input is a number
        MONITOR_DURATION=$new_duration
        echo "Monitoring duration changed to $MONITOR_DURATION seconds."
    else
        echo "Invalid input. Please enter a number."
    fi
}

# Main loop
while true; do
    clear
    display_menu
    read -p "Enter your choice [1-7]: " choice

    case $choice in
        1)  # CPU Usage
            cpu_usage=$(get_cpu_usage)
            echo "Current CPU Usage: $cpu_usage"
            ;;
        2)  # Memory Usage
            memory_usage=$(get_memory_usage)
            echo "Current Memory Usage: $memory_usage"
            ;;
        3)  # Disk Space
            disk_usage=$(get_disk_usage)
            echo "Current Disk Space Usage: $disk_usage"
            ;;
        4)  # View Log File
            view_log_file
            ;;
        5)  # Continuous Monitoring
            monitor_resources
            ;;
        6)  # Change Monitoring Duration
            change_duration
            ;;
        7)  # Exit
            echo "Exiting..."
            exit 0
            ;;
        *)  # Invalid Choice
            echo "Invalid choice. Please enter a number between 1 and 7."
            ;;
    esac

    read -p "Press Enter to continue..."
done


#!/bin/bash

LOGFILE="/var/log/health_monitor.log"
THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=90
INTERVAL=30

log_alert() {
    echo "$(date): $1" | tee -a $LOGFILE
}

while true; do
    # CPU usage (%)
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if (( $(echo "$CPU > $THRESHOLD_CPU" | bc -l) )); then
        log_alert "ALERT: High CPU usage: ${CPU}% (>${THRESHOLD_CPU}%)"
    fi

    # Memory usage (%)
    MEM=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ $MEM -gt $THRESHOLD_MEM ]; then
        log_alert "ALERT: High memory usage: ${MEM}% (>${THRESHOLD_MEM}%)"
    fi

    # Disk usage on / (%)
    DISK=$(df / | awk 'NR==2{print $5}' | cut -d'%' -f1)
    if [ $DISK -gt $THRESHOLD_DISK ]; then
        log_alert "ALERT: High disk usage on /: ${DISK}% (>${THRESHOLD_DISK}%)"
    fi

    # Running processes (count > 500 as example threshold)
    PROC_COUNT=$(ps aux | wc -l)
    if [ $PROC_COUNT -gt 500 ]; then
        log_alert "ALERT: High process count: ${PROC_COUNT} (>500)"
    fi

    sleep $INTERVAL
done
#!/bin/bash
set -euo pipefail

# Resolve project root path
ROOT_DIR=$(dirname "$(realpath "$0")")/..
LOG="$ROOT_DIR/logs/metrics.log"
CONF="$ROOT_DIR/config/thresholds.conf"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Load configuration
if [ -f "$CONF" ]; then
    source "$CONF"
else
    echo "Error: Configuration file $CONF not found."
    exit 1
fi

# Gather Metrics
# CPU: Get idle time and subtract from 100
cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print $1}')
cpu=$(echo "100 - $cpu_idle" | bc)

# Memory: Usage percentage
mem=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')

# Disk: Usage percentage of root /
disk=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

# Log current specific metrics
echo "$DATE cpu=$cpu% mem=$mem% disk=$disk%" >> "$LOG"

# Check Thresholds and Alert if necessary (Using python notifier)
# Note: bc returns 1 for true, 0 for false

# CPU Check
if (( $(echo "$cpu > $CPU_LIMIT" | bc -l) )); then
    python3 "$ROOT_DIR/alerts/notifier.py" "CPU usage critical: $cpu% (Limit: $CPU_LIMIT%)"
fi

# Memory Check
if (( $(echo "$mem > $MEM_LIMIT" | bc -l) )); then
    python3 "$ROOT_DIR/alerts/notifier.py" "Memory usage critical: $mem% (Limit: $MEM_LIMIT%)"
fi

# Disk Check
if [ "$disk" -gt "$DISK_LIMIT" ]; then
    python3 "$ROOT_DIR/alerts/notifier.py" "Disk usage critical: $disk% (Limit: $DISK_LIMIT%)"
    # Auto-remediation trigger
    bash "$ROOT_DIR/bin/remediate.sh" disk
fi

# Service Check
# Check if services in services.conf are running
if [ -f "$ROOT_DIR/config/services.conf" ]; then
    while read -r svc; do
        if [ ! -z "$svc" ]; then
            if ! systemctl is-active --quiet "$svc"; then
                 python3 "$ROOT_DIR/alerts/notifier.py" "Service DOWN: $svc. Triggering restart."
                 bash "$ROOT_DIR/bin/remediate.sh" service "$svc"
            fi
        fi
    done < "$ROOT_DIR/config/services.conf"
fi

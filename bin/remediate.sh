#!/bin/bash
set -euo pipefail

# Resolve project root path
ROOT_DIR=$(dirname "$(realpath "$0")")/..
ACTION=$1
TARGET=${2:-""} # Optional target (e.g. service name)

LOG="$ROOT_DIR/logs/alerts.log"

log_action() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") [REMEDIATION] $1" >> "$LOG"
}

case $ACTION in
  disk)
    log_action "Starting disk cleanup..."
    
    # 1. Clean /tmp
    log_action "Cleaning /tmp directory..."
    # Warning: Be careful with rm -rf in production scripts. 
    # checking if /tmp is not empty before attempting cleanup to avoid errors
    if [ "$(ls -A /tmp)" ]; then
        rm -rf /tmp/* 2>/dev/null || true
    fi
    
    # 2. Vacuum Systemd Journals (retain last 2 days)
    log_action "Vacuuming systemd journals..."
    journalctl --vacuum-time=2d 2>/dev/null || true
    
    # 3. Clean package manager cache (Generic attempt for apt/yum)
    if command -v apt-get &> /dev/null; then
        apt-get clean
    elif command -v yum &> /dev/null; then
        yum clean all
    fi
    
    log_action "Disk cleanup completed."
    ;;

  service)
    if [ -z "$TARGET" ]; then
        echo "Error: Service name required for remediation."
        exit 1
    fi
    
    log_action "Attempting to restart service: $TARGET"
    sudo systemctl restart "$TARGET"
    
    if systemctl is-active --quiet "$TARGET"; then
        log_action "SUCCESS: Service $TARGET successfully restarted."
    else
        log_action "FAILURE: Could not restart service $TARGET. Manual intervention required."
    fi
    ;;

  *)
    echo "Usage: $0 {disk|service <service_name>}"
    exit 1
    ;;
esac

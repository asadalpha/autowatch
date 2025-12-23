#!/bin/bash
set -e

# Get the root directory of the project
ROOT_DIR=$(dirname "$(realpath "$0")")

echo "Initializing Autowatch SentinelOps..."

# Create necessary directories if they don't exist
mkdir -p "$ROOT_DIR/logs"

# Initialize log files
touch "$ROOT_DIR/logs/metrics.log"
touch "$ROOT_DIR/logs/alerts.log"

# Make scripts executable
chmod +x "$ROOT_DIR/bin/"*.sh

echo "---------------------------------------"
echo "✅ Environment initialized successfully."
echo "Logs located in: $ROOT_DIR/logs/"
echo "Run monitoring manually: $ROOT_DIR/bin/monitor.sh"
echo "---------------------------------------"

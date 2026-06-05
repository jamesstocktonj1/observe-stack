#!/usr/bin/env bash
set -euo pipefail

# Load DATA_DIR from .env if present, default to ./data
DATA_DIR="./data"
if [ -f .env ]; then
    value=$(grep -E '^DATA_DIR=' .env | cut -d= -f2-)
    [ -n "$value" ] && DATA_DIR="$value"
fi

# Derive container names from the compose project (directory name by default)
PROJECT=$(basename "$(pwd)")
PROMETHEUS_CONTAINER="${PROJECT}-prometheus-1"
GRAFANA_CONTAINER="${PROJECT}-grafana-1"

echo "Using DATA_DIR: $DATA_DIR"
echo "Expecting containers: $PROMETHEUS_CONTAINER, $GRAFANA_CONTAINER"
echo ""

# Verify containers are running
for container in "$PROMETHEUS_CONTAINER" "$GRAFANA_CONTAINER"; do
    if ! docker inspect --format '{{.State.Running}}' "$container" 2>/dev/null | grep -q true; then
        echo "ERROR: $container is not running. Aborting."
        exit 1
    fi
done

# Create destination directories
mkdir -p "$DATA_DIR/prometheus" "$DATA_DIR/grafana" "$DATA_DIR/jaeger"

# Copy data out of running containers
echo "Copying Prometheus data..."
docker cp "$PROMETHEUS_CONTAINER:/prometheus/." "$DATA_DIR/prometheus/"

echo "Copying Grafana data..."
docker cp "$GRAFANA_CONTAINER:/var/lib/grafana/." "$DATA_DIR/grafana/"

# Fix ownership so containers can write after restart
echo "Fixing permissions..."
sudo chown -R 65534:65534 "$DATA_DIR/prometheus"
sudo chown -R 472:472     "$DATA_DIR/grafana"
sudo chown -R 10001:10001 "$DATA_DIR/jaeger"

# Restart with new config
echo "Restarting stack..."
docker compose down
docker compose up -d

echo ""
echo "Migration complete. Data is now persisted at $DATA_DIR"

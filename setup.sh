#!/usr/bin/env bash
set -euo pipefail

# Load DATA_DIR from .env if present, default to ./data
DATA_DIR="./data"
if [ -f .env ]; then
    value=$(grep -E '^DATA_DIR=' .env | cut -d= -f2-)
    [ -n "$value" ] && DATA_DIR="$value"
fi

echo "Using DATA_DIR: $DATA_DIR"

mkdir -p "$DATA_DIR/prometheus" "$DATA_DIR/grafana" "$DATA_DIR/jaeger"

sudo chown -R 65534:65534 "$DATA_DIR/prometheus"
sudo chown -R 472:472     "$DATA_DIR/grafana"
sudo chown -R 10001:10001 "$DATA_DIR/jaeger"

echo "Done. Run 'docker compose up -d' to start the stack."

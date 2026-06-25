#!/usr/bin/env bash
set -euo pipefail

# Load DATA_DIR from .env if present, default to ./data
DATA_DIR="./data"
if [ -f .env ]; then
    value=$(grep -E '^DATA_DIR=' .env | cut -d= -f2-)
    [ -n "$value" ] && DATA_DIR="$value"
fi

echo "Using DATA_DIR: $DATA_DIR"

mkdir -p "$DATA_DIR/clickhouse" "$DATA_DIR/grafana"

sudo chown -R 101:101 "$DATA_DIR/clickhouse"
sudo chown -R 472:472 "$DATA_DIR/grafana"

echo "Done. Run 'docker compose up -d' to start the stack."

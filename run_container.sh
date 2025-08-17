#!/bin/bash
set -euo pipefail
BASE="/volume1/docker/article_scraper"
ENV_FILE="$BASE/.env"
LOG_DIR="$BASE/logs"
LOG_FILE="$LOG_DIR/$(date +%Y%m%d)_run.log"
mkdir -p "$LOG_DIR"
docker run --rm \
  -v "$BASE":/app \
  -w /app \
  --env-file "$ENV_FILE" \
  python:3.11-slim \
  bash -lc 'pip install -r requirements.txt >/dev/null && python main.py --keyword 日本 --limit 5' \
  > "$LOG_FILE" 2>&1
tail -n 50 "$LOG_FILE"

#!/usr/bin/env bash
set -euo pipefail

echo "→ Pulling latest n8n image…"
docker pull n8nio/n8n:latest

echo "→ Launching new container…"
docker compose up -d --quiet-pull

echo "→ Purging dangling images…"
docker image prune -f

echo "✔ Upgrade complete."

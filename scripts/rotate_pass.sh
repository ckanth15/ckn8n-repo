#!/usr/bin/env bash
# Usage: ./rotate_pass.sh <new_password>

set -euo pipefail
NEW_PASS=$1

sed -i "s/N8N_BASIC_AUTH_PASSWORD=.*/N8N_BASIC_AUTH_PASSWORD=${NEW_PASS}/" docker-compose.yml
docker compose up -d --quiet-pull

echo "✔ Basic-auth password rotated."

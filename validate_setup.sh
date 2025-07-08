#!/usr/bin/env bash
set -euo pipefail
HOST=<your-website-domain>

if ! docker ps --format '{{.Names}}' | grep -q '^n8n$'; then
  echo "✗ n8n container is not running" && exit 1
fi

for PORT in 80 443; do
  if ! nc -z -w2 "$HOST" "$PORT"; then
    echo "✗ Port $PORT closed on $HOST" && exit 1
  fi
done

if ! systemctl is-active --quiet nginx; then
  echo "✗ NGINX service is inactive" && exit 1
fi

echo "✔ Validation successful: n8n, NGINX, and ports look good."

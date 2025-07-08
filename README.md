# n8n DigitalOcean Deployment Kit

This repository contains everything needed to spin up a **secure, production-ready n8n instance** on DigitalOcean.  
Includes Docker Compose, NGINX reverse‑proxy config, helper scripts, and a validation check.

## Contents

```
.
├── docker-compose.yml          # n8n container definition
├── nginx/
│   └── n8n.conf                # Reverse proxy + TLS
├── scripts/
│   ├── rotate_pass.sh          # Rotate basic‑auth password
│   └── upgrade_n8n.sh          # Pull & redeploy latest image
├── validate_setup.sh           # End‑to‑end health check
└── README.md                   # This file
```

## Quick start

```bash
# 1. Copy files to your server (or git clone after pushing to GitHub)
scp -r . root@143.198.106.101:/root/n8n-deploy

# 2. On the server
cd /root/n8n-deploy
docker compose up -d
```

_See the full deployment guide for detailed instructions and hardening tips._

## Publish to GitHub

```bash
git init
git add .
git commit -m "Initial DigitalOcean n8n deployment kit"
git remote add origin git@github.com:<your-username>/n8n-digitalocean-deploy.git
git branch -M main
git push -u origin main
```

Happy automating!  
Generated on 2025-07-08

# n8n DigitalOcean Deployment Guide

> **One‑click stack to self‑host n8n with HTTPS on any Linux VM (Droplet, EC2, Vultr, etc.)**

---

## Tech Stack & System Requirements

| Component | Version | Purpose |
|-----------|---------|---------|
| Ubuntu | 24.10 LTS | Host OS |
| Docker Engine | 25.0+ | Container runtime |
| Docker Compose v2 | 2.27+ | Orchestrator |
| n8n | 1.45.0 | Automation platform |
| NGINX | 1.24+ | Reverse proxy & TLS termination |
| Certbot | 2.10+ | Let’s Encrypt client |

*Minimum hardware:* 1 vCPU / 1 GB RAM works for light workloads. Scale as needed.

---

## Overview
This repository contains everything needed to spin up a **production‑ready, SSL‑secured n8n instance** on a fresh Ubuntu server:

- Docker Compose configuration  
- Hardened NGINX reverse‑proxy with automatic Let’s Encrypt certificates  
- Persistent volume mapping for n8n data  
- Helper scripts for upgrades, password rotation, and health checks  
- Documentation covering domain, firewall, and cross‑provider tips  

---

## Table of Contents

1. [Domain and DNS Configuration](#domain-and-dns-configuration)  
2. [NGINX Reverse Proxy Setup](#nginx-reverse-proxy-setup)  
3. [SSL with Let’s Encrypt](#ssl-with-lets-encrypt)  
4. [Firewall Configuration](#firewall-configuration)  
5. [Docker Volumes for Persistence](#docker-volumes-for-persistence)  
6. [Password & Environment Management](#password--environment-management)  
7. [Owner Account](#owner-account)  
8. [Automation & Scripts](#automation--scripts)  
9. [Troubleshooting](#troubleshooting)  
10. [Cross‑Provider Usage & Git](#cross-provider-usage--git)  
11. [Free vs Paid Components](#free-vs-paid-components)  
12. [Validation Script](#validation-script)  

---

## Quick Start

```bash
# 1. Copy project to your server (or git clone after pushing)
scp -r . root@<your-instance-public-ip>:/root/n8n-deploy

# 2. On the server
cd /root/n8n-deploy
docker compose up -d
```

---

## Domain and DNS Configuration

1. Register a domain (e.g. `example.com`)  
2. Add *A* record(s) pointing to `<your-instance-public-ip>`  

| Host | Type | Value |
|------|------|-------|
| @    |  A   | `<your-instance-public-ip>` |
| n8n  |  A   | `<your-instance-public-ip>` |

Verify propagation:

```bash
nslookup n8n.example.com
```

---

## NGINX Reverse Proxy Setup

### Install NGINX

```bash
apt update && apt install -y nginx
```

`nginx/n8n.conf` in this repo already contains an HTTP→HTTPS redirect, WebSocket headers, and secure defaults. Symlink and reload:

```bash
ln -s $(pwd)/nginx/n8n.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

---

## SSL with Let’s Encrypt

```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d n8n.example.com
```

Certbot will:

1. Place ACME challenge files on **port 80**  
2. Obtain certs in `/etc/letsencrypt/live/…`  
3. Edit the NGINX file to add `ssl_certificate` lines & 301 redirect  
4. Reload NGINX  

Renewal runs automatically via systemd timer.

---

## Firewall Configuration

```bash
ufw allow OpenSSH
ufw allow "Nginx Full"   # opens 80 & 443
ufw enable
```

If your provider also has a cloud firewall (DigitalOcean, AWS), open the same ports there.

---

## Docker Volumes for Persistence

Flows, credentials, and logs live in `/home/node/.n8n` inside the container.  
`docker-compose.yml` mounts this to `./n8n_data` on the host:

```yaml
volumes:
  - ./n8n_data:/home/node/.n8n
```

Create it (and fix UID):

```bash
mkdir -p n8n_data
chown 1000:1000 n8n_data
```

---

## Password & Environment Management

`docker-compose.yml` exposes environment variables:

```yaml
- N8N_BASIC_AUTH_ACTIVE=true
- N8N_BASIC_AUTH_USER=admin
- N8N_BASIC_AUTH_PASSWORD=<strong-password>
- N8N_HOST=<your-instance-public-ip>
- N8N_SECURE_COOKIE=false  # turn true after HTTPS works
```

### Rotate the password

```bash
./scripts/rotate_pass.sh newSecret123
```

---

## Owner Account

After the first launch, n8n prompts you to *“Set up owner account”*.  
This **internal user** controls workflows and is **separate** from HTTP Basic Auth.

---

## Automation & Scripts

| Script | Purpose |
|--------|---------|
| `scripts/rotate_pass.sh` | Change Basic‑Auth password & hot‑reload container |
| `scripts/upgrade_n8n.sh` | Pull latest image, redeploy, prune old layers |
| `validate_setup.sh` | Health check: container, ports, NGINX |

Add them to cron or CI as needed.

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|------|
| `502 Bad Gateway` | Container down / wrong port | `docker logs -f n8n` |
| Certbot fails | Port 80 blocked / DNS typo | Check UFW & `dig` |
| Owner setup loop | `N8N_SECURE_COOKIE=true` behind HTTP | Flip to `false`, restart |

---

## Cross‑Provider Usage & Git

This stack is **cloud‑agnostic**. Anywhere you can install Docker you can:

```bash
git clone https://github.com/<you>/n8n-digitalocean-deploy.git
cd n8n-digitalocean-deploy
docker compose up -d
```

Update only the domain & IP.

---

## Free vs Paid Components

| Component | Free Tier | Paid Upgrade |
|-----------|-----------|--------------|
| n8n | Self‑hosted OSS | n8n Cloud, priority support |
| Domain | — | Registrar ~$10/yr |
| SSL | Let’s Encrypt | EV / OV certs |
| Hosting | $5 DO Droplet | Larger VM / Managed K8s |
| Support | Community | SLA support |

---

## Validation Script

Run any time to verify container + ports + NGINX:

```bash
./validate_setup.sh
```

---

### Generated 2025-07-08

Feel free to open issues or PRs!

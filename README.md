# Self-Hosted Application Stack

## Apps

### Caddy

Purpose: route applications as subdomains of home.arpa (e.g. paperless.home.arpa).

External configuration:
- Must set each subdomain to point to server internal IP address in router hosts file.

### Paperless-ngx

Purpose: document storage.

## Management scripts

### compose-all.sh

Usage: `./_scripts/compose-all.sh [args]`:

Runs `docker compose [args]` for each app. Useful to bring all services up or down.

Examples:
  - `./_scripts/compose-all.sh down`
  - `./_scripts/compose-all.sh up -d`

# Self-Hosted Application Stack

## Apps

### Caddy

Purpose: route applications as subdomains of home.arpa (e.g. paperless.home.arpa).

External configuration:
- Must set each subdomain to point to server internal IP address in router hosts file.

### Paperless-ngx

Purpose: document storage.

### OpenCloud

Purpose: general files.

## Management scripts

### compose-all.sh

Usage: `./_scripts/compose-all.sh [args]`

Runs `docker compose [args]` for each app. Useful to bring all services up or down.

Examples:
  - `./_scripts/compose-all.sh down`
  - `./_scripts/compose-all.sh up -d`

### backup-all.sh

Usage: `./_scripts/backup-all.sh`

Script actions:
1. Runs `pre-backup` services under the `backup` profile (e.g. to run database backups).
2. Stops all apps.
3. Runs `restic backup /opt/apps /srv/apps` to `/backup/apps-backup` using `/backup/restic-password.txt` and `restic-exclude.txt`.
4. Starts all apps.

### restore-all.sh

Usage: `./_scripts/restore-all.sh`

Prerequisites:
- Install `docker` and `docker compose`.
- Install `git` and clone this repo to `/opt/apps`.
- Download `restic` and copy to `/usr/local/bin/restic`.
- Mount restic repo to `/backup/apps-backup` and create `/backup/restic-password.txt`.

Script actions:
1. Creates `/srv/apps` and sets owner if it doesn't exist.
2. Creates the `reverse-proxy` docker network if it doesn't exist.
2. Runs `restic restore latest` from `/backup/apps-backup` using `/backup/restic-password.txt`.
3. Runs `post-restore` services under the `restore` profile (e.g. to restore database from backups).
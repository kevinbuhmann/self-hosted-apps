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

Prerequisites:
- Ensure that the `./backup-restore/.env` file is properly configured.

Script actions:
1. Runs `pre-backup` services under the `backup` profile (e.g. to run database backups).
2. Stops all apps.
3. Runs `restic backup /opt/apps /srv/apps` to `RESTIC_REPO` using `RESTIC_PASSWORD_FILE` and `./backup-restore/restic-exclude.txt`.
4. Starts all apps.

### restore-all.sh

Usage: `./_scripts/restore-all.sh`

Prerequisites:
- Install `docker` and `docker compose`.
- Install `git` and clone this repo to `/opt/apps`.
- Ensure that the `./backup-restore/.env` file is properly configured.

Script actions:
1. Creates `/srv/apps` and sets owner if it doesn't exist.
2. Creates the `apps-reverse-proxy` docker network if it doesn't exist.
3. Runs `restic restore latest` from `RESTIC_REPO` using `RESTIC_PASSWORD_FILE`.
4. Runs `post-restore` services under the `restore` profile (e.g. to restore database from backups).

# Self-Hosted Application Stack

## Apps

### Caddy

Purpose: route applications as subdomains of the configured base domain (`BASE_DOMAIN` in the root `.env` file).

External configuration:

- Must set each subdomain to point to server internal IP address in router hosts file.

### Paperless-ngx

Purpose: document storage.

### Obsidian LiveSync

Purpose: sync Obsidian notes between devices

## Management scripts

### backup-all.sh

Usage: `./_scripts/backup-all.sh`

Prerequisites:

- Ensure that the `./backup-restore/.env` file is properly configured.

Script actions:

1. Runs `pre-backup` services under the `backup` profile (e.g. to run database backups).
2. Stops all apps.
3. Runs `restic backup /opt/apps /srv/apps` to `RESTIC_REPO` using `RESTIC_PASSWORD_FILE` and `./backup-restore/restic-exclude.txt`.
4. Starts all apps.
5. Runs `rclone sync` using `RCLONE_CONFIG_FILE` and `RCLONE_TARGET` if restic backup was successful.

### restore-all.sh

Usage: `./_scripts/restore-all.sh`

Prerequisites:

- Install `docker` and `docker compose`.
- Install `git` and clone this repo to `/opt/apps`.
- Ensure that the `./backup-restore/.env` file is properly configured.
- Restore the off-site backup if needed using `./_scripts/run-rclone.sh restore`.

Script actions:

1. Creates `/srv/apps` and sets owner if it doesn't exist.
2. Runs `restic restore latest` from `RESTIC_REPO` using `RESTIC_PASSWORD_FILE`.
3. Runs `post-restore` services under the `restore` profile (e.g. to restore database from backups).

### run-clone.sh

Usage: `./_scripts/restore-all.sh <backup|restore`>

Prerequistes:

- Install `docker` and `docker compose`.
- Ensure that the `./backup-restore/.env` file is properly configured.

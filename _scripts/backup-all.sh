#!/usr/bin/env bash
set -euo pipefail

# Set user/group IDs for container user mapping.
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"
echo "Running backup as user: $USER"

# Build the backup-restore container, exit upon failure.
docker compose --file ./backup-restore/docker-compose.yaml --profile backup build

# Run pre-backup hooks for all services before shutting them down (e.g. to run database backups).
./_scripts/run-service-all.sh pre-backup --profile backup

# Shut down all services before performing the backup.
./_scripts/compose-all.sh down

# Perform the backup using restic.
echo
backup_failed=0
docker compose --file ./backup-restore/docker-compose.yaml --profile backup run --rm restic-backup || backup_failed=1

# Bring all services back up after the backup is complete.
./_scripts/compose-all.sh up -d

# Report result.
echo
if [ "$backup_failed" -eq 0 ]; then
  echo -e "\e[32mBackup succeeded and services are running.\e[0m"
else
  echo -e "\e[31mServices are running, but the backup failed.\e[0m" >&2
fi

exit "$backup_failed"

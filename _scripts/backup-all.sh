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
restic_backup_failed=0
docker compose --file ./backup-restore/docker-compose.yaml --profile backup run --rm restic-backup || restic_backup_failed=1

# Bring all services back up after the restic backup is complete, even if it failed.
compose_up_failed=0
./_scripts/compose-all.sh up -d || compose_up_failed=1

# Run rclone backup after successful restic backup.
rclone_backup_failed=0
if [ "$restic_backup_failed" -eq 0 ]; then
  echo
  ./_scripts/run-rclone.sh backup || rclone_backup_failed=1
fi

# Report result.
echo
if [ "$restic_backup_failed" -ne 0 ]; then
  echo -e "\e[31mThe restic backup failed.\e[0m" >&2
elif [ "$rclone_backup_failed" -ne 0 ]; then
  echo -e "\e[31mThe rclone backup failed.\e[0m" >&2
else
  echo -e "\e[32mBackup succeeded.\e[0m"
fi

if [ "$compose_up_failed" -ne 0 ]; then
  echo -e "\e[31mFailed to bring services back up after backup.\e[0m" >&2
else
  echo -e "\e[32mServices are running.\e[0m"
fi

exit "$((restic_backup_failed || compose_up_failed ||rclone_backup_failed))"

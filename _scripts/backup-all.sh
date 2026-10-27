#!/usr/bin/env bash
set -euo pipefail

echo "Running backup as user: $USER"

# Run pre-backup hooks for all services before shutting them down (e.g. to run database backups).
./_scripts/run-service-all.sh pre-backup --profile backup

# Shut down all services before performing the backup.
./_scripts/compose-all.sh down

# Perform the backup using restic.
backup_command=(
  env RESTIC_PASSWORD_FILE=/backup/restic-password.txt
  restic -r /backup/apps-backup backup /opt/apps /srv/apps --exclude-file ./restic-exclude.txt
)

backup_failed=0
if "${backup_command[@]}"; then
  echo
  echo -e "\e[32mBackup succeeded.\e[0m"
else
  backup_failed=1

  echo
  echo -e "\e[31mBackup failed.\e[0m" >&2
fi

# Bring all services back up after the backup is complete.
./_scripts/compose-all.sh up -d

# Report result.
if [ "$backup_failed" -eq 0 ]; then
  echo
  echo -e "\e[32mBackup succeeded and services are running.\e[0m"
else
  echo
  echo -e "\e[31mServices are running, but the backup failed.\e[0m" >&2
fi

exit "$backup_failed"

#!/usr/bin/env bash
set -euo pipefail

echo "Running restore as user: $USER"

# Prerequisite: Run restic restore.
# This script assumes that is already done because this script would be restored from the restic repo.

# Create /srv/apps if it doesn't exist.
sudo mkdir -p /srv/apps
sudo chown "$USER":"$USER" /srv/apps # set ownership for the current user
sudo setfacl -R -m u:"$USER":rwx /srv/apps # set ACL for the current user recursively
sudo setfacl -dR -m u:"$USER":rwx /srv/apps # set default ACL for the current user recursively

# Create the reverse proxy docker network if it doesn't exist.
docker network create reverse-proxy || true

# Perform the restore using restic.
restore_command=(
  env RESTIC_PASSWORD_FILE=/backup/restic-password.txt
  restic -r /backup/apps-backup restore latest --target /
)

if "${restore_command[@]}"; then
  echo
  echo -e "\e[32mRestore succeeded.\e[0m"
else
  echo
  echo -e "\e[31mRestore failed.\e[0m" >&2
  exit 1
fi

# Run post-restore hooks for all services (e.g. to restore database from backups).
./_scripts/run-service-all.sh post-restore --profile restore

# Bring all services up.
./_scripts/compose-all.sh up -d

echo -e "\e[32mRestore succeeded and services are running.\e[0m"

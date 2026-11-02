#!/usr/bin/env bash
set -euo pipefail

# Prerequisite 1: Run `git clone https://github.com/kevinbuhmann/self-hosted-apps.git /opt/apps`
# This script assumes that is already done because this script would be from the cloned repository.

# Prerequisite 2: Ensure that the backup files are available.
# - /backup/apps-backup: restic repo
# - /backup/restic-password.txt: password for the above restic repo

echo "Running restore as user: $USER"

# Create /srv/apps if it doesn't exist.
sudo mkdir -p /srv/apps
sudo chown "$USER":"$USER" /srv/apps # set ownership for the current user
sudo setfacl -R -m u:"$USER":rwx /srv/apps # set ACL for the current user recursively
sudo setfacl -dR -m u:"$USER":rwx /srv/apps # set default ACL for the current user recursively

# Create the reverse proxy docker network if it doesn't exist.
docker network create apps-reverse-proxy --internal || true

# Perform the restore using restic.
echo
restore_failed=0
env RESTIC_PASSWORD_FILE=/backup/restic-password.txt restic -r /backup/apps-backup restore latest --target / || restore_failed=1

if [ "$restore_failed" -eq 0 ]; then
  echo -e "\e[32mRestore succeeded.\e[0m"
else
  echo -e "\e[31mRestore failed.\e[0m" >&2
  exit "$restore_failed"
fi

# Run post-restore hooks for all services (e.g. to restore database from backups).
./_scripts/run-service-all.sh post-restore --profile restore

# Bring all services up.
./_scripts/compose-all.sh up -d

echo -e "\e[32mRestore succeeded and services are running.\e[0m"

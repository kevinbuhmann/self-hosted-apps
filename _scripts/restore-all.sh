#!/usr/bin/env bash
set -euo pipefail

# Prerequisite 1: Run `git clone https://github.com/kevinbuhmann/self-hosted-apps.git /opt/apps`
# This script assumes that is already done because this script would be from the cloned repository.

# Prerequisite 2: Ensure that the backup files are available and the backup-restore/.env file is properly configured.
# See the backup-restore/.env.template file and set the RESTIC_REPO and RESTIC_PASSWORD_FILE variables accordingly.
# If the restic repo is not available locally, you will need to download it from the offsite backup location manually
# or run `./_scripts/run-rclone.sh restore` (after satisfying the prerequisites stated in that script).

# Set user/group IDs for container user mapping.
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"
echo "Running restore as user: $USER"

# Build the backup-restore container, exit upon failure.
docker compose --file ./backup-restore/docker-compose.yaml --profile backup build

# Create /srv/apps if it doesn't exist.
sudo mkdir -p /srv/apps
sudo chown "$USER":"$USER" /srv/apps # set ownership for the current user
sudo setfacl -R -m u:"$USER":rwx /srv/apps # set ACL for the current user recursively
sudo setfacl -dR -m u:"$USER":rwx /srv/apps # set default ACL for the current user recursively

# Perform the restore using restic.
echo
restore_failed=0
docker compose --file ./backup-restore/docker-compose.yaml --profile restore run --rm restic-restore || restore_failed=1

if [ "$restore_failed" -ne 0 ]; then
  exit "$restore_failed"
fi

# Run post-restore hooks for all services (e.g. to restore database from backups).
./_scripts/run-service-all.sh post-restore

# Bring all services up.
docker compose up -d

echo -e "\e[32mRestore succeeded and services are running.\e[0m"

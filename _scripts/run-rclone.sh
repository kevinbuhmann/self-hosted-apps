#!/usr/bin/env bash
set -euo pipefail

# Prerequisite: Ensure that the backup-restore/.env file is properly configured.

if [[ $# -ne 1 || ("$1" != "backup" && "$1" != "restore") ]]; then
  echo "Usage: $0 <backup|restore>"
  exit 1
fi

echo "Running $1 as user: $USER"
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

docker compose --file ./backup-restore/docker-compose.yaml --profile $1 run --rm rclone-$1

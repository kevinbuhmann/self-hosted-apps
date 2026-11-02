#!/bin/sh
set -eu

printf '\033[34mStarting restic backup...\033[0m\n'

# Set a writable cache location inside the container.
RESTIC_CACHE_DIR=/tmp/restic-cache
export RESTIC_CACHE_DIR
mkdir -p "$RESTIC_CACHE_DIR"

# Perform the backup using restic.
backup_failed=0
restic backup /opt/apps /srv/apps --host $RESTIC_HOST --repo /restic-repo --password-file /restic-password.txt --exclude-file /restic-exclude.txt || backup_failed=1

# Report result.
if [ "$backup_failed" -eq 0 ]; then
  printf '\033[32mRestic backup succeeded.\033[0m\n'
else
  printf '\033[31mRestic backup failed.\033[0m\n' >&2
  exit 1
fi

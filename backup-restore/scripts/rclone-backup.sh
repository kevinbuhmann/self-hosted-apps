#!/bin/sh
set -eu

printf '\033[34mUploading restic backup via rclone...\033[0m\n'

# Copy config to /tmp to allow rclone to manage access tokens.
cp /rclone.conf /tmp/rclone.conf

# Perform the rclone backup.
backup_failed=0
rclone sync /restic-repo "$RCLONE_TARGET" --config /tmp/rclone.conf --progress || backup_failed=1

# Copy possibly-updated config back to source file.
cat /tmp/rclone.conf > /rclone.conf

# Report result.
if [ "$backup_failed" -eq 0 ]; then
  printf '\033[32mRclone backup succeeded.\033[0m\n'
else
  printf '\033[31mRclone backup failed.\033[0m\n' >&2
  exit 1
fi

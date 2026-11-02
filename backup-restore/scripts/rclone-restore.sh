#!/bin/sh
set -eu

printf '\033[34mDownloading restic backup via rclone...\033[0m\n'

# Copy config to /tmp to allow rclone to manage access tokens.
cp /rclone.conf /tmp/rclone.conf

# Perform the rclone restore.
restore_failed=0
rclone sync "$RCLONE_TARGET" /restic-repo --config /tmp/rclone.conf --progress || restore_failed=1

# Copy possibly-updated config back to source file.
cat /tmp/rclone.conf > /rclone.conf

# Change ownership of the restored files to the host user.
chown "$HOST_UID:$HOST_GID" /restic-repo --recursive

# Report result.
if [ "$restore_failed" -eq 0 ]; then
  printf '\033[32mRclone restore succeeded.\033[0m\n'
else
  printf '\033[31mRclone restore failed.\033[0m\n' >&2
  exit 1
fi

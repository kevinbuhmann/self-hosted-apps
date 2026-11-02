#!/bin/sh
set -eu

if [ $# -ne 1 ] || { [ "$1" != "backup" ] && [ "$1" != "restore" ]; }; then
  echo "Usage: $0 <backup|restore>"
  exit 1
fi

printf "\033[34mStarting rclone $1...\033[0m\n"

# Copy config to /tmp to allow rclone to manage access tokens.
cp /rclone.conf /tmp/rclone.conf

# Perform the rclone backup.
action_failed=0
if [ "$1" = "backup" ]; then
  rclone sync /restic-repo "$RCLONE_TARGET" --config /tmp/rclone.conf --progress --checksum || action_failed=1
elif [ "$1" = "restore" ]; then
  rclone sync "$RCLONE_TARGET" /restic-repo --config /tmp/rclone.conf --progress --checksum || action_failed=1
fi

# Copy possibly-updated config back to source file.
cat /tmp/rclone.conf > /rclone.conf

# Report result.
if [ "$action_failed" -eq 0 ]; then
  printf "\033[32mRclone $1 succeeded.\033[0m\n"
else
  printf "\033[31mRclone $1 failed.\033[0m\n" >&2
  exit 1
fi

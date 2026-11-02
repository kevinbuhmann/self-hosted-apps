#!/bin/sh
set -eu

if [ $# -ne 1 ] || { [ "$1" != "backup" ] && [ "$1" != "restore" ]; }; then
  echo "Usage: $0 <backup|restore>"
  exit 1
fi

echo -e "\e[34mStarting restic $1...\e[0m\n"

# Set a writable cache location inside the container.
RESTIC_CACHE_DIR=/tmp/restic-cache
export RESTIC_CACHE_DIR
mkdir -p "$RESTIC_CACHE_DIR"

# Perform the requested action using restic.
action_failed=0
if [ "$1" = "backup" ]; then
  restic backup /opt/apps /srv/apps --host $RESTIC_HOST --repo /restic-repo --password-file /restic-password.txt --exclude-file /restic-exclude.txt || action_failed=1
elif [ "$1" = "restore" ]; then
  restic restore latest --target / --repo /restic-repo --password-file /restic-password.txt || action_failed=1
fi

# Report result.
if [ "$action_failed" -eq 0 ]; then
  echo -e "\e[32mRestic $1 succeeded.\e[0m\n"
else
  echo -e "\e[31mRestic $1 failed.\e[0m\n" >&2
  exit 1
fi

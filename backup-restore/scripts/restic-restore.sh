#!/bin/sh
set -eu

printf '\033[34mStarting restic restore...\033[0m\n'

# Set a writable cache location inside the container.
RESTIC_CACHE_DIR=/tmp/restic-cache
export RESTIC_CACHE_DIR
mkdir -p "$RESTIC_CACHE_DIR"

# Perform the restore using restic.
restore_failed=0
restic restore latest --target / --repo /restic-repo --password-file /restic-password.txt || restore_failed=1

# Report result.
if [ "$restore_failed" -eq 0 ]; then
  printf '\033[32mRestic restore succeeded.\033[0m\n'
else
  printf '\033[31mRestic restore failed.\033[0m\n' >&2
  exit 1
fi

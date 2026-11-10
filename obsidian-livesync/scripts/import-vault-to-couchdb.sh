#!/bin/bash
set -e

SCRIPT_DIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"

echo "Setting up livesync-cli..."
"$SCRIPT_DIR/setup-livesync-cli.sh"

echo "Rebuilding database from /vault..."
livesync-cli rebuild --force --vault /vault
echo "Rebuild complete!"

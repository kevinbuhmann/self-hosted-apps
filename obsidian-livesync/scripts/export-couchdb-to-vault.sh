#!/bin/bash
set -e

SCRIPT_DIR="$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")"

echo "Setting up livesync-cli..."
"$SCRIPT_DIR/setup-livesync-cli.sh"

echo "Fetching vault to /vault..."
rm -rf /vault/*
livesync-cli fetch --force --vault /vault
echo "Fetch complete!"

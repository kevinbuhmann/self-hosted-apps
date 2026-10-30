#!/bin/sh
set -e

# 1. Ensure the directories exist on the host filesystem
mkdir -p /etc/opencloud /var/lib/opencloud

# 2. Automatically generate the flawless configuration file if missing
if [ ! -f /etc/opencloud/opencloud.yaml ]; then
    echo "No configuration file found. Running automatic initialization..."
    opencloud init --insecure false --admin-password "${INITIAL_ADMIN_PASSWORD}"
else
    echo "Configuration file already exists. Skipping generation."
fi

# 3. Securely hand over folder ownership to OpenCloud's required UID (1000)
echo "Applying permission masks for user 1000..."
chown -R 1000:1000 /etc/opencloud /var/lib/opencloud

echo "Initialization step completed successfully!"

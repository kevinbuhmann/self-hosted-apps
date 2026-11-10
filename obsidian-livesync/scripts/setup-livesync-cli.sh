#!/bin/bash
set -e

rm -rf /data/*
mkdir -p /data/.livesync

cat << EOF > /data/.livesync/settings.json
{
  "couchDB_URI": "$COUCHDB_INTERNAL_URL",
  "couchDB_USER": "$COUCHDB_USER",
  "couchDB_PASSWORD": "$COUCHDB_PASSWORD",
  "couchDB_DBNAME": "$COUCHDB_DATABASE",
  "e2ee": true,
  "obfuscate_properties": true,
  "passphrase": "$LIVESYNC_PASSPHRASE"
}
EOF

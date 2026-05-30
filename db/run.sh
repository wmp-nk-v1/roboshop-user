#!/usr/bin/env bash
set -e

[ -f /data/params ] && set -a && source /data/params && set +a

: "${MONGO_URL:?MONGO_URL is required}"

echo "Waiting for MongoDB..."
until mongosh "$MONGO_URL" --eval "db.adminCommand('ping')" --quiet 2>/dev/null; do
    echo "MongoDB not ready, retrying in 2s..."
    sleep 2
done

echo "Seeding user database..."
mongosh "$MONGO_URL" --file /db/master-data.js
echo "User database setup complete"

#!/usr/bin/env bash
set -e

: "${MONGODB_HOST:?MONGODB_HOST is required}"

MONGO_URL="mongodb://${MONGODB_HOST}:27017/users"

echo "Waiting for MongoDB at ${MONGODB_HOST}..."
until mongosh "$MONGO_URL" --eval "db.adminCommand('ping')" --quiet 2>/dev/null; do
    echo "MongoDB not ready, retrying in 2s..."
    sleep 2
done

echo "Seeding user database..."
mongosh "$MONGO_URL" --file /db/master-data.js
echo "User database setup complete"

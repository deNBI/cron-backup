#!/bin/sh

# Temporär Edge-Repositories hinzufügen (nur für PostgreSQL 18)
echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories

apk update && apk add --no-cache postgresql18-client

echo "Installed dependencies"

declare -p | grep -E 'POSTGRES_HOST|POSTGRES_USER|POSTGRES_DB|POSTGRES_PORT|POSTGRES_PASSWORD' >> /container.env

echo "Environment was set"

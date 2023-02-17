#!/bin/sh

apk update && apk add --no-cache postgresql-client

echo "Installed dependencies"

declare -p | grep -E 'POSTGRES_HOST|POSTGRES_USER|POSTGRES_DB|POSTGRES_PORT|POSTGRES_PASSWORD' >> /container.env

echo "Environment was set"

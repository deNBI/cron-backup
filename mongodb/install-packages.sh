#!/bin/sh

apk update && apk add --no-cache mongodb-tools
echo "Installed dependencies"

declare -p | grep -E 'MONGODB_DB|MONGODB_HOST|MONGODB_USER|MONGODB_PASSWORD' >>/container.env

echo "Environment was set"

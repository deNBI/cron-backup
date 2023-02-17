#!/bin/sh

apk update && apk add --no-cache mariadb-client
echo "Installed dependencies"

declare -p | grep -E 'MYSQL_HOST|MYSQL_USER|MYSQL_PASSWORD' >>/container.env

echo "Environment was set"

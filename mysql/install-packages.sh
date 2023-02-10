#!/bin/sh

apt-get  update && apt-get install -y mariadb-client
echo "Installed dependencies"

declare -p | grep -E 'MYSQL_HOST|MYSQL_USER|MYSQL_PASSWORD' >>/container.env

echo "Environment was set"

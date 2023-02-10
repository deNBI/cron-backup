#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get   update && apt-get install -y postgresql-client


echo "Installed dependencies"

declare -p | grep -E 'POSTGRES_HOST|POSTGRES_USER|POSTGRES_DB' >>/container.env

echo "Environment was set"

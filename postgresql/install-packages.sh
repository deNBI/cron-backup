#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get   update && apt-get install -y postgresql-client-common

echo "Installed dependencies"
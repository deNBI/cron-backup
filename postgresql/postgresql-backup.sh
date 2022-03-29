#!/bin/sh
touch ~/.pgpass
echo ${POSTGRES_HOST}:${POSTGRES_PORT}:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD} > ~/.pgpass
chmod 600 ~/.pgpass

export PGPASSFILE='/root/.pgpass'

NOW=$(date '+%y-%m-%d-%H%M')
FILE=/etc/backup/${POSTGRES_DB}-${NOW}.dump.gz
echo "Create Backup $FILE"

pg_dump -h ${POSTGRES_HOST}  -U ${POSTGRES_USER} ${POSTGRES_DB}  -Z  9 > $FILE





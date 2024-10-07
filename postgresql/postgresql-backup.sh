#!/bin/sh

# Define a logging function
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}

# Set up an error trap to exit the script on any error
trap 'log "Error occurred, exiting script"; exit 1' ERR

# Create the ~/.pgpass file if it doesn't exist
if [ ! -f "~/.pgpass" ]; then
  touch ~/.pgpass
  log "Created ~/.pgpass file"
fi

# Set the PostgreSQL connection details as environment variables
POSTGRES_HOST=${POSTGRES_HOST:-}
POSTGRES_PORT=${POSTGRES_PORT:-5432} # default to 5432 if not set
POSTGRES_DB=${POSTGRES_DB:-}
POSTGRES_USER=${POSTGRES_USER:-}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}

# Check that all required environment variables are set
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
  log "Error: Missing PostgreSQL connection details, exiting script"
  exit 1
fi

# Set the PGPASSFILE environment variable to point to the ~/.pgpass file
export PGPASSFILE='/root/.pgpass'

# Write the PostgreSQL connection details to the ~/.pgpass file
echo "${POSTGRES_HOST}:${POSTGRES_PORT}:${POSTGRES_DB}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" > ~/.pgpass

# Set permissions on the ~/.pgpass file
chmod 600 ~/.pgpass

# Create a timestamp for the backup file name
NOW=$(date '+%y-%m-%d-%H%M')

# Define the backup file path and name
FILE="/etc/backup/${POSTGRES_DB}-${NOW}.dump.gz"

log "Creating Backup $FILE"

# Perform the PostgreSQL database dump
pg_dump -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" "${POSTGRES_DB}" -Z 9 > "$FILE"

# Check if the backup file is not empty and has a reasonable size
MIN_SIZE=$((1024 * 10)) # 10KB minimum size
if [ ! -s "$FILE" ] || [ $(stat -c%s "$FILE") -lt $MIN_SIZE ]; then
  log "Backup file $FILE is too small (${MIN_SIZE}B required), aborting script"
  exit 1
fi

# Send a notification using the notify_uptime_kuma.sh script
if ! /notify_uptime_kuma.sh; then
  log "Failed to send notification"
fi

log "Backup completed successfully"
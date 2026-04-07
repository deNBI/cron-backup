#!/bin/bash

# Set KUMA_STATUS_ENDPOINT variable from environment or default to empty string
S3_KUMA_STATUS_ENDPOINT=${S3_KUMA_STATUS_ENDPOINT:-}
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] - $1"
}
if [ -z "$S3_KUMA_STATUS_ENDPOINT" ]; then
    log "INFO: S3_KUMA_STATUS_ENDPOINTT is not set. Skipping."
else
    # Use curl to make a GET request to the status endpoint
    response=$(curl -s -X GET "$S3_KUMA_STATUS_ENDPOINT")

    # Check if the request was successful
    if [ $? -eq 0 ]; then
        log "S3 Status endpoint responded successfully: $response"
    else
        log "Error: Failed to push status from S3-Status $S3_KUMA_STATUS_ENDPOINT. Status code: $?"
    fi
fi
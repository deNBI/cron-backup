#!/bin/bash

# Set KUMA_STATUS_ENDPOINT variable from environment or default to empty string
KUMA_STATUS_ENDPOINT=${KUMA_STATUS_ENDPOINT:-}

if [ -z "$KUMA_STATUS_ENDPOINT" ]; then
    echo "INFO: KUMA_STATUS_ENDPOINT is not set. Skipping."
else
    # Use curl to make a GET request to the status endpoint
    response=$(curl -s -X GET "$KUMA_STATUS_ENDPOINT")

    # Check if the request was successful
    if [ $? -eq 0 ]; then
        echo "Status endpoint responded successfully: $response"
    else
        echo "Error: Failed to push status from $KUMA_STATUS_ENDPOINT. Status code: $?"
    fi
fi
#!/bin/bash

# Set S3_KUMA_STATUS_ENDPOINT variable from environment or default to empty string
S3_KUMA_STATUS_ENDPOINT=${S3_KUMA_STATUS_ENDPOINT:-}

if [ -z "$S3_KUMA_STATUS_ENDPOINT" ]; then
    echo "Error: S3_KUMA_STATUS_ENDPOINT is not set. Skipping."
else
    # Use curl to make a POST request to the status endpoint
    response=$(curl -s -X POST \\
        "$S3_KUMA_STATUS_ENDPOINT")

    # Check if the request was successful
    if [ $? -eq 0 ]; then
        echo "Status endpoint responded successfully: $response"
    else
        echo "Error: Failed to send status update to $S3_KUMA_STATUS_ENDPOINT. Status code: $?"
    fi
fi
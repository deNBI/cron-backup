#!/bin/bash

KUMA_STATUS_ENDPOINT=${KUMA_STATUS_ENDPOINT}

if [ -z "$KUMA_STATUS_ENDPOINT" ]; then
    echo "KUMA_STATUS_ENDPOINT is not set. Skipping."
else
    curl -X POST \\
        $KUMA_STATUS_ENDPOINT
fi
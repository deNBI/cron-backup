#!/bin/bash

S3_KUMA_STATUS_ENDPOINT=${S3_KUMA_STATUS_ENDPOINT}

if [ -z "$KUMA_STATUS_ENDPOINT" ]; then
    echo "S3_KUMA_STATUS_ENDPOINT is not set. Skipping."
else
    curl -X POST \\
        $S3_KUMA_STATUS_ENDPOINT
fi
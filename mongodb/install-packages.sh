#!/bin/sh
set -e

# Install base tools and compatibility layer for glibc binaries on Alpine
apk update && apk add --no-cache wget tar libc6-compat

# Download official MongoDB Database Tools
# Version 106.0.0 is used here; this should be updated as newer versions are released
VERSION="106.0.0"
FILENAME="mongodb-database-tools-linux-x86_64-ubuntu2204-v${VERSION}.tgz"
URL="https://fastdl.mongodb.org/tools/db/${FILENAME}"

echo "Downloading MongoDB Database Tools v${VERSION}..."
wget -q "$URL"

# Extract and move binaries to the path
tar -xzf "$FILENAME"
# The archive contains a directory named mongodb-database-tools-linux-x86_64-ubuntu2204-v${VERSION}
EXTRACT_DIR="mongodb-database-tools-linux-x86_64-ubuntu2204-v${VERSION}"
mv "${EXTRACT_DIR}/bin/"* /usr/local/bin/

# Cleanup
rm -rf "$EXTRACT_DIR"
rm "$FILENAME"

echo "Installed latest MongoDB Tools v${VERSION} successfully"

# Export environment variables to container.env
declare -p | grep -E 'MONGODB_DB|MONGODB_HOST|MONGODB_USER|MONGODB_PASSWORD' >>/container.env

echo "Environment was set"

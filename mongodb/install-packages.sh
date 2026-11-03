#!/bin/sh
set -e
# Install base tools and compatibility layer for glibc binaries on Alpine
apk update && apk add --no-cache wget tar libc6-compat

# Download official MongoDB Database Tools
# Version 100.20.1 is the current stable version
VERSION="100.20.1"
FILENAME="mongodb-database-tools-debian13-x86_64-${VERSION}.tgz"
URL="https://fastdl.mongodb.org/tools/db/${FILENAME}"

echo "Downloading MongoDB Database Tools v${VERSION}..."
# Use -O to ensure the file is saved with the exact filename we expect
wget -q -O "$FILENAME" "$URL"

# Extract and move binaries to the path
tar -xzf "$FILENAME"
# The archive contains a directory named after the filename
EXTRACT_DIR="mongodb-database-tools-debian13-x86_64-${VERSION}"
mv "${EXTRACT_DIR}/bin/"* /usr/local/bin/

# Cleanup
rm -rf "$EXTRACT_DIR"
rm "$FILENAME"

echo "Installed latest MongoDB Tools v${VERSION} successfully"

# Export environment variables to container.env
declare -p | grep -E 'MONGODB_DB|MONGODB_HOST|MONGODB_USER|MONGODB_PASSWORD' > /container.env || true
echo "Environment was set"

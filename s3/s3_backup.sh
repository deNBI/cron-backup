#!/bin/bash

# Backup directory specific
basedir="/etc/backup"
s3path=$S3_PATH

find  $S3_CONFIGS_PATH  -type f  -name "*.cfg"| while read -r a; do
  echo "$a"

  . $a
  echo $S3_ACCESS_KEY
  done
  s3cmd mb s3://$S3_PATH
  cd $basedir

  if [ ! -d "$S3_HASHDIR" ]; then
    mkdir -p "$S3_HASHDIR"
  fi

  #Find all files within this directory and it's subdirs
  find * -type f | while read -r a; do

    fnamehash=$(echo "$a" | sha1sum | cut -d\  -f1)
    filehash=$(sha1sum "$a" | cut -d\  -f1)
    source "$S3_HASHDIR/$fnamehash" 2>/dev/null

    if [ "$filehash" != "$storedhash" ]; then
      s3cmd put -e $a s3://$S3_PATH/$a
      if [ $? -eq 0]; then
      echo "storedhash='$filehash'" >"$S3_HASHDIR/$fnamehash"
      fi
    else
      # Hashes match, no need to push
      echo "$a unchanged, skipping......"
    fi

  done
done
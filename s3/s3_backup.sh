#!/bin/bash

# Backup directory specific
basedir="/etc/backup"
s3path=$S3_PATH
tmp_conf=/root/tmp.cfg

find  $S3_CONFIGS_PATH  -type f  -name "*.cfg"| while read -r env_data; do
  echo "$env_data"
  . "$env_data"
  rm -f "$tmp_conf"
  touch "$tmp_conf"
    printf "%s\n" "[default]" >> "$tmp_conf"
  printf "%s\n" "access_key = $S3_ACCESS_KEY" >> "$tmp_conf"
  printf "%s\n" "gpg_passphrase = $S3_ENCRYPT_PASSPHRASE" >> "$tmp_conf"
  printf "%s\n" "host_base = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  printf "%s\n" "host_bucket = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  printf "%s\n" "secret_key = $S3_SECRET_KEY" >> "$tmp_conf"
  printf "%s\n" "gpg_command = /usr/bin/gpg" >> "$tmp_conf"
  printf "%s\n" "gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s" >> "$tmp_conf"
  printf "%s\n" "gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s" >> "$tmp_conf"






  s3cmd -c "$tmp_conf"  mb s3://$S3_PATH
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
      s3cmd -c "$tmp_conf" put  -e $a s3://$S3_PATH/$a
      if [ $? -eq 0 ]; then
      echo "storedhash='$filehash'" >"$S3_HASHDIR/$fnamehash"
      fi
    else
      # Hashes match, no need to push
      echo "$a unchanged, skipping......"
    fi

  done
done

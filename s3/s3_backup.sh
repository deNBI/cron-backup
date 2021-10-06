#!/bin/bash

# Backup directory specific
basedir="/etc/backup"
unencrypted_copy="/etc/unencrypted"
mkdir -p $unencrypted_copy
cp -a $basedir/. $unencrypted_copy
fdupes -qdiN -r $unencrypted_copy
s3path=$S3_PATH
tmp_conf=/root/tmp.cfg
tmp_pass=/root/pass.txt
find  $S3_CONFIGS_PATH  -type f  -name "*.cfg"| while read -r env_data; do
  echo "$env_data"
  config_name=$(basename -- $env_data)
  site_name="${config_name%.*}"
  baseEncryptDir="/etc/encrypted/backup/"$site_name
  echo $baseEncryptDir
  mkdir -p $baseEncryptDir


  . "$env_data"
  rm -f "$tmp_conf"
  rm -f "$tmp_pass"

  touch "$tmp_pass"
    printf "%s" $S3_ENCRYPT_PASSPHRASE"" >> "$tmp_pass"


  touch "$tmp_conf"
  printf "%s\n" "[default]" >> "$tmp_conf"
  printf "%s\n" "access_key = $S3_ACCESS_KEY" >> "$tmp_conf"
  printf "%s\n" "host_base = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  printf "%s\n" "host_bucket = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  printf "%s\n" "secret_key = $S3_SECRET_KEY" >> "$tmp_conf"






  s3cmd -c "$tmp_conf"  mb s3://$S3_PATH
  cd $unencrypted_copy

  #Find all files within this directory and it's subdirs
  find * -type f | while read -r a; do
    if [ ! -f $baseEncryptDir/$a.gpg ]; then
    echo "Encrypting $a"
    if [[ $a =~ "/" ]]; then
    dir=$(echo $a | rev | cut -d'/' -f2- | rev)

    mkdir -p $baseEncryptDir/$dir
    fi
    gpg --batch -o $baseEncryptDir/$a.gpg  -c --passphrase-file $tmp_pass $a
    fi


  done

  s3cmd -c "$tmp_conf" -v sync --acl-private  $baseEncryptDir s3://$S3_PATH

rm -f "$tmp_conf"
  rm -f "$tmp_pass"
done

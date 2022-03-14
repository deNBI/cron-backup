#!/bin/bash

# Backup directory specifi
s3path=$S3_PATH
tmp_conf=/root/tmp.cfg
find $S3_CONFIGS_PATH -type f -name "*.cfg" | while read -r env_data; do
  s3path=$S3_PATH
  echo "$env_data"
  config_name=$(basename -- $env_data)
  site_name="${config_name%.*}"
  s3path=$s3path/$site_name/
  echo $s3path
  . "$env_data"
  echo "Delete Files uploaded more than $S3_BACKUP_ROTATION_TIME_LIMIT days ago..."
  rm -f "$tmp_conf"

  touch "$tmp_conf"
  printf "%s\n" "[default]" >>"$tmp_conf"
  printf "%s\n" "access_key = $S3_ACCESS_KEY" >>"$tmp_conf"
  printf "%s\n" "host_base = $S3_OBJECT_STORAGE_EP" >>"$tmp_conf"
  printf "%s\n" "host_bucket = $S3_OBJECT_STORAGE_EP" >>"$tmp_conf"
  printf "%s\n" "secret_key = $S3_SECRET_KEY" >>"$tmp_conf"

  s3cmd -c "$tmp_conf" ls s3://$s3path | grep " DIR " -v | while read -r line; do
    echo "$line"
    createDate=$(echo $line | awk {'print $1" "$2'})
    createDate=$(date -d "$createDate" "+%s")
    olderThan=$(date -d "@$(($(date +%s) - 86400 * $S3_BACKUP_ROTATION_TIME_LIMIT))" +%s)
    fileName=$(echo $line | awk {'print $4'})

    if [[ $createDate -le $olderThan ]]; then
      if [ $fileName != "" ]; then
        printf '    Deleting "%s"\n' $fileName
        s3cmd -c "$tmp_conf" del "$fileName"
      fi

    else
      echo "   File $fileName still valid"

    fi
  done

  rm -f "$tmp_conf"
done

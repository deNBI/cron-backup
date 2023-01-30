#!/bin/bash

# Backup directory specific S3 path
s3_path=$S3_PATH
tmp_conf=/root/tmp.cfg

find $S3_CONFIGS_PATH -type f -name "*.cfg" | while read -r env_data; do
  s3_path=$S3_PATH
  config_name=$(basename -- $env_data)
  site_name="${config_name%.*}"
  s3_path=$s3_path/$site_name/
  base_encrypt_dir="/etc/encrypted/backup/$site_name"

  # Load environment data
  . "$env_data"

  # Create temporary S3 configuration file
  echo "Creating temporary S3 configuration file at $tmp_conf"
  echo "[default]" > "$tmp_conf"
  echo "access_key = $S3_ACCESS_KEY" >> "$tmp_conf"
  echo "host_base = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  echo "host_bucket = $S3_OBJECT_STORAGE_EP" >> "$tmp_conf"
  echo "secret_key = $S3_SECRET_KEY" >> "$tmp_conf"

  # Delete files uploaded more than the specified limit
  echo "Deleting files uploaded more than $S3_BACKUP_ROTATION_TIME_LIMIT days ago..."
  s3cmd -c "$tmp_conf" ls "s3://$s3_path" | grep -v " DIR " | while read -r line; do
    create_date=$(date -d "$(echo $line | awk '{ print $1" "$2 }')" "+%s")
    older_than=$(date -d "@$(($(date +%s) - 86400 * $S3_BACKUP_ROTATION_TIME_LIMIT))" +%s)
    file_name=$(echo $line | awk '{ print $4 }')

    if [[ $create_date -le $older_than ]]; then
      if [ $file_name != "" ]; then
        echo "Deleting $file_name in S3"
        s3cmd -c "$tmp_conf" del "$file_name"
        pure_file_name=$(echo "$file_name" | awk -F'/' '{ print $NF }')
        echo "Also deleting local encrypted file $base_encrypt_dir/$pure_file_name if it still exists"
        rm -f "$base_encrypt_dir/$pure_file_name"
        unencrypted_file=/etc/unencrypted/$pure_file_name
      fi
    fi
  done
done
        unencryptedFile=${unencryptedFile%.gpg}
        printf 'Delete local unencrypted file "%s" if it still exists\n' $unencryptedFile
        rm -f $unencryptedFile
      fi

    else
      echo "   File $fileName still valid"

    fi
  done

  rm -f "$tmp_conf"
done

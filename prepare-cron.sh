#!/bin/bash

if [ "$BACKUP_ROTATION_ENABLED" == "true" ]; then
  cp /rotate_backup.sh /etc/cronscripts/rotate_backup.sh
  cat /backup-cron >>/etc/crontabs/dockercron/*
  declare -p | grep -E 'BACKUP_ROTATION_MAX_SIZE|BACKUP_ROTATION_CUT_SIZE|BACKUP_ROTATION_SIZE_TYPE' >>/container.env

fi
if [ "$S3_BACKUP_ENABLED" == "true" ]; then
  cp /s3_backup.sh /etc/cronscripts/s3_backup.sh
  cat /s3_backup-cron >>/etc/crontabs/dockercron/*
  declare -p | grep -E 'S3_PATH|S3_HASHDIR|S3_OBJECT_STORAGE_EP|S3_ACCESS_KEY|S3_SECRET_KEY|S3_ENCRYPT_PASSPHRASE|S3_CONFIGS_PATH' >>/container.env

  if [ "$S3_BACKUP_ROTATION_ENABLED" == "true" ]; then
    cp /s3_backup_rotation.sh /etc/cronscripts/s3_backup_rotation.sh
    cat /s3_backup_rotation-cron >>/etc/crontabs/dockercron/*
    declare -p | grep -E 'S3_BACKUP_ROTATION_TIME_LIMIT' >>/container.env
  fi

fi




if [ -f "/install-packages.sh" ]; then
  echo "Running install packages"

  chmod +x /install-packages.sh
  bash /install-packages.sh
  echo "Packages installed!"
fi

chmod +x /etc/cronscripts/*
crontab /etc/crontabs/dockercron/*
echo "Cronjob setup done"

echo "Starting crond and tail"
crond -b -l 6 && tail -f /var/log/cron.log

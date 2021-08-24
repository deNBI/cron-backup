#!/bin/bash

chmod +x /install-packages.sh
sh /install-packages.sh
if [ "$BACKUP_ROTATION_ENABLED" == "true" ]; then
  cp /rotate_backup.sh /etc/cronscripts/rotate_backup.sh
  cat /backup-cron >>/etc/crontabs/dockercron/*
  declare -p | grep -E 'BACKUP_ROTATION_MAX_SIZE|BACKUP_ROTATION_CUT_SIZE|BACKUP_ROTATION_SIZE_TYPE' >/container.env

fi
chmod +x /etc/cronscripts/*
crontab /etc/crontabs/dockercron/*
crond -b -l 6 && tail -f /var/log/cron.log

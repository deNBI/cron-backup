FROM busybox:latest
RUN apk add --no-cache bash
RUN apk update && apk add python3 py3-pip
RUN pip3 install s3cmd
RUN touch /var/log/cron.log
COPY ./prepare-cron.sh /prepare-cron.sh
COPY ./backup/rotate_backup.sh /rotate_backup.sh
COPY ./backup/backup-cron /backup-cron
COPY ./s3/s3_backup.sh /s3_backup.sh
COPY ./s3/s3_backup-cron /s3_backup-cron
COPY ./s3/s3_backup_rotation.sh /s3_backup_rotation.sh
COPY ./s3/s3_backup_rotation-cron /s3_backup_rotation-cron
RUN chmod +x /prepare-cron.sh
ENTRYPOINT ["/prepare-cron.sh"]

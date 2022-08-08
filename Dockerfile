FROM python:alpine3.16
RUN apk add  --no-cache bash gnupg fdupes
RUN pip install s3cmd
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

FROM python:alpine3.14
RUN apk add  --no-cache bash gnupg
RUN pip install s3cmd
RUN touch /var/log/cron.log
COPY ./prepare-cron.sh /prepare-cron.sh
COPY ./backup/rotate_backup.sh /rotate_backup.sh
COPY ./s3/s3_backup.sh /s3_backup.sh
COPY ./s3/s3_backup-cron /s3_backup.sh
COPY ./s3/s3cmd.cfg /root/.s3cfg
COPY ./backup/backup-cron /backup-cron
RUN chmod +x /prepare-cron.sh
ENTRYPOINT ["/prepare-cron.sh"]

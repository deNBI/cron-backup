FROM alpine:3.14.0
RUN apk add  --no-cache bash
RUN touch /var/log/cron.log
COPY ./prepare-cron.sh /prepare-cron.sh
COPY ./backup/rotate_backup.sh /rotate_backup.sh
COPY ./backup/backup-cron /backup-cron
RUN chmod +x /prepare-cron.sh
ENTRYPOINT ["/prepare-cron.sh"]

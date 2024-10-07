FROM alpine:3.20.3
ARG DEBIAN_FRONTEND=noninteractive

RUN apk add --update --no-cache \
    bash \
    gnupg \
    fdupes \
    python3 \
    py3-pip \
    curl \
    busybox-extras \
    ssmtp

RUN pip3 install --upgrade pip  --break-system-packages
RUN pip3 install s3cmd  --break-system-packages

RUN touch /var/log/cron.log

COPY ./prepare-cron.sh /prepare-cron.sh
COPY ./backup/rotate_backup.sh /rotate_backup.sh
COPY ./backup/backup-cron /backup-cron
COPY ./backup/notify_uptime_kuma.sh /notify_uptime_kuma.sh

COPY ./s3/s3_backup.sh /s3_backup.sh
COPY ./s3/s3_backup-cron /s3_backup-cron
COPY ./s3/s3_backup_rotation.sh /s3_backup_rotation.sh
COPY ./s3/s3_backup_rotation-cron /s3_backup_rotation-cron
COPY ./s3/s3_notify_uptime_kuma.sh /s3_notify_uptime_kuma.sh

RUN chmod +x /prepare-cron.sh

ENTRYPOINT ["/prepare-cron.sh"]


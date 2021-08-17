FROM alpine:3.14.0
RUN touch /var/log/cron.log
COPY ./prepare-cron.sh /prepare-cron.sh
RUN chmod +x /prepare-cron.sh
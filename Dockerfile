FROM alpine:latest

COPY ./scripts/* /etc/periodic/15min

RUN apk update && apk add openssh bash mariadb-client

RUN chmod a+x /etc/periodic/15min/*

CMD cron && tail -f /var/log/cron.log
FROM alpine:latest

COPY ./scripts/* /etc/periodic/hourly

RUN apk update && apk add openssh bash mariadb-client

RUN chmod a+x /etc/periodic/hourly/*

ENTRYPOINT ["tail", "-f", "/dev/null"]
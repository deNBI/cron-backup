FROM alpine:3.14.0

ARG CRONTAB_FILE=mysql-cron
ARG SCRIPTS_FOLDER=mysqlbackup
ARG PACKAGES_FILE=mysqlbackup.txt

COPY ./packages/${PACKAGES_FILE} /etc/pkginstall/packages.txt
COPY ./crontabs/${CRONTAB_FILE} /etc/crontabs/dockercron
COPY ./scripts/${SCRIPTS_FOLDER} /etc/cronscripts/

RUN export PACKAGES=$(cat /etc/pkginstall/packages.txt)
RUN apk update && apk add $PACKAGES

RUN chmod +x /etc/cronscripts/*

RUN crontab /etc/crontabs/dockercron

CMD crond
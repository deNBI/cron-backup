FROM alpine:3.14.0

ARG CRONTAB_FILE
ARG SCRIPTS_FOLDER
ARG PACKAGES_FILE

ADD ./packages/$PACKAGES_FILE /etc/pkginstall/packages.txt
ADD ./crontabs/$CRONTAB_FILE /etc/crontabs/dockercron
ADD ./scripts/$SCRIPTS_FOLDER /etc/cronscripts

RUN export PACKAGES=$(cat packages.txt)
RUN apk update && apk add $PACKAGES

RUN chmod +x /etc/cronscripts/*

RUN crontab /etc/crontabs/dockercron

CMD ['crond' '-f']
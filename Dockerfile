FROM alpine:3.14.0

ENV CRONTAB_FILE=$CRONTAB_FILE
ENV SCRIPTS_FOLDER=$SCRIPTS_FOLDER
ENV PACKAGES_FILE=$PACKAGES_FILE

ADD ./packages/$PACKAGES_FILE /etc/pkginstall/packages.txt
ADD ./crontabs/$CRONTAB_FILE /etc/crontabs/dockercron
ADD ./scripts/$SCRIPTS_FOLDER /etc/cronscripts/

RUN export PACKAGES=$(cat packages.txt)
RUN apk update && apk add $PACKAGES

RUN chmod +x /etc/cronscripts/*

RUN crontab /etc/crontabs/dockercron

CMD crond
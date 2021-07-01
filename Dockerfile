FROM oxys/alpine-docker-cron:latest

RUN apk update && apk add openssh bash

ADD run.sh /run.sh
ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /run.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh

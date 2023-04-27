ARG BASE_TAG=latest
FROM quay.io/denbicloud/cron-backup:${BASE_TAG}

COPY ./install-packages.sh /install-packages.sh
COPY ./mongodb-backup.sh /etc/cronscripts/mongodb-backup.sh
COPY ./mongodb-cron /etc/crontabs/dockercron/mongodb-cron

RUN chmod +x /install-packages.sh && bash /install-packages.sh

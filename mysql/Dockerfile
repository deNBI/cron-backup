ARG BASE_TAG=latest
FROM quay.io/denbicloud/cron-backup:${BASE_TAG}

COPY ./install-packages.sh /install-packages.sh
COPY ./mysql-backup.sh /etc/cronscripts/mysql-backup.sh
COPY ./mysql-cron /etc/crontabs/dockercron/mysql-cron

RUN chmod +x /install-packages.sh && bash /install-packages.sh

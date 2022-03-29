ARG BASE_TAG=latest
FROM denbicloud/cron-backup:${BASE_TAG}
COPY ./install-packages.sh /install-packages.sh
COPY ./mysql-backup.sh /etc/cronscripts/mysql-backup.sh
COPY ./mysql-cron /etc/crontabs/dockercron/mysql-cron
RUN chmod +x /install-packages.sh
RUN sh /install-packages.sh
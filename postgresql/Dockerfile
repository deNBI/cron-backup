ARG BASE_TAG=latest
FROM denbicloud/cron-backup:${BASE_TAG}
COPY ./install-packages.sh /install-packages.sh
COPY ./postgresql-backup.sh /etc/cronscripts/postgresql-backup.sh
COPY ./postgresql-cron /etc/crontabs/dockercron/postgresql-cron
RUN chmod +x /install-packages.sh
RUN sh /install-packages.sh
ARG BASE_TAG=latest@sha256:da7505ae3308347f7faac4d9cfd384a741f8455ce67dfa77a22983b0fed99d3d
ARG DEBIAN_FRONTEND=noninteractive

FROM oci.bi.denbi.de/denbicloud/cron-backup:${BASE_TAG}


COPY ./install-packages.sh /install-packages.sh
COPY ./postgresql-backup.sh /etc/cronscripts/postgresql-backup.sh
COPY ./postgresql-cron /etc/crontabs/dockercron/postgresql-cron

RUN chmod +x /install-packages.sh && bash /install-packages.sh

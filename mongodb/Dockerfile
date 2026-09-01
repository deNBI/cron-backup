ARG BASE_TAG=latest@sha256:da7505ae3308347f7faac4d9cfd384a741f8455ce67dfa77a22983b0fed99d3d
FROM oci.bi.denbi.de/denbicloud/cron-backup:${BASE_TAG}

COPY ./install-packages.sh /install-packages.sh
COPY ./mongodb-backup.sh /etc/cronscripts/mongodb-backup.sh
COPY ./mongodb-cron /etc/crontabs/dockercron/mongodb-cron

RUN chmod +x /install-packages.sh && bash /install-packages.sh

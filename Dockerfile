FROM ubuntu:latest

ADD ./scripts/mysql-cron /etc/cron.d/mysql-cron
ADD ./scripts/mysql_backup.sh /etc/mysqlcron/mysql_backup.sh

RUN chmod 0644 /etc/cron.d/mysql-cron

RUN touch /var/log/cron.log

RUN apt update
RUN apt install cron

CMD cron && tail -f /var/log/cron.log
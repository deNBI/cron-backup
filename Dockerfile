FROM ubuntu:latest

ADD ./scripts/mysql-cron /etc/cron.d/crontab
ADD ./scripts/mysql_backup.sh /etc/mysqlcron/mysql_backup.sh

RUN chmod 0644 /etc/cron.d/crontab
run chmod +x /etc/mysqlcron/mysql_backup.sh

RUN apt update
RUN apt install -y cron
RUN apt install -y mariadb-client
RUN crontab /etc/cron.d/crontab

CMD cron -f 
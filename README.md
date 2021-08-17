# Cron-Backup

Containered cron jobs based on an [Alpine Linux image](https://hub.docker.com/_/alpine). 
This image offers a minimal base image with a shell script to prepare and run cron jobs.
To use this you need to create:

1. A install-packages.sh:  
   A shell script which installs the dependencies you need.

2. A cronscript:  
   A script which runs the steps to backup your data.

3. A crontab:  
   A crontab when to run your cronscript. This image offers a log file (located under /var/log/cron.log) to which you 
   may log your output, which is used by directing all output to stdout 
   (i.e. * * * * * /mycronscript >> /var/log/cron.log 2>&1).

Next use this image with your docker-compose.yml (here an exmaple for a limesurvey/mysql backup container):

```
  limesurvey_backup:
      container_name: limesurvey_backup
      image: denbicloud/cron-backup
      volumes:
        - ./config/cron/limesurvey/install-packages.sh:/install-packages.sh
        - ./config/cron/limesurvey/mysql-backup.sh:/etc/cronscripts/mysql-backup.sh
        - ./config/cron/limesurvey/mysql-cron:/etc/crontabs/dockercron/mysql-cron
        - ${general_PERSISTENT_PATH}backup/limesurvey:/etc/backup
      environment:
        - LIMESURVEY_DB_PASSWORD
      networks:
        - portal
      command: "bash /prepare-cron.sh && crond -b -l 6 && tail -f /var/log/cron.log"
```

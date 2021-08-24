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
   
4. This image supports backup rotation, therefore the BACKUP_ENABLED=true environemnt variable must be set.
   Following env variables must/can be set:
   
   * BACKUP_ROTATION_ENABLED - must be set to true to activate the Backup Rotation
   * BACKUP_ROTATION_MAX_SIZE - Max Size of Backup folder (default 2)
   * BACKUP_ROTATION_CUT_SIZE - Size to which the folder will be trimmed (default 1)
   * BACKUP_ROTATION_SIZE_TYPE - Type of the Size ( default GiB - possible Types MB MiB GB GiB TB TiB)

Next use this image with your docker-compose.yml (here an example for a limesurvey/mysql backup container):

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
        - BACKUP_ROTATION_ENABLED=true
        - BACKUP_ROTATION_MAX_SIZE=10
        - BACKUP_ROTATION_CUT_SIZE=5
        - BACKUP_ROTATION_SIZE_TYPE=GiB
      networks:
        - portal
```

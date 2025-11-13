# Cron-Backup

Containered cron jobs based on an [Alpine Linux image](https://hub.docker.com/_/alpine). This image offers a minimal
base image with a shell script to prepare and run cron jobs. To use this you need to create:

1. A install-packages.sh:  
   A shell script which installs the dependencies you need.

2. A cronscript:  
   A script which runs the steps to backup your data.

3. A crontab:  
   A crontab when to run your cronscript. This image offers a log file (located under /var/log/cron.log) to which you
   may log your output, which is used by directing all output to stdout
   (i.e. * * * * * /mycronscript >> /var/log/cron.log 2>&1).

4. This image supports backup rotation, therefore the BACKUP_ENABLED=true environemnt variable must be set. Following
   env variables must/can be set:

    * BACKUP_ROTATION_ENABLED - must be set to true to activate the Backup Rotation
    * BACKUP_ROTATION_MAX_SIZE - Max Size of Backup folder (default 2)
    * BACKUP_ROTATION_CUT_SIZE - Size to which the folder will be trimmed (default 1)
    * BACKUP_ROTATION_SIZE_TYPE - Type of the Size ( default GiB - possible Types MB MiB GB GiB TB TiB)
    * BACKUP_MAX_DAYS -   Maximum age (in days) for backups. Default: 90.
   

5. This image supports pushing the backups encrypted to S3 Storage. Following env variables must be set:

    - S3_BACKUP_ENABLED=true - must be set to true to activate S3 Backup
    - S3_PATH - the Name of the Container which will be created in OpenStack (global - can be overwritten per site.cfg)
    - S3_ENCRYPT_PASSPHRASE - Set for encryption (global - can be overwritten per site.cfg)
    - S3_CONFIGS_PATH - Directory of the different site configs with variables see below (should be mounted)
    - S3_BACKUP_ROTATION_ENABLED - must to set to true to activate backup rotation in S3
    - S3_BACKUP_ROTATION_TIME_LIMIT -  expiration time in days for Backups - if rotation is enabled uploads older than this limit will be removed - (global - can be overwirtten per site.cfg)
    - S3_KUMA_STATUS_ENDPOINT - when provided will be called after an successfull backup

   In addition, a cfg must be specified for each site to which the backups are to be pushed - with the following content [example](s3/configs/example.site.cfg):
6. An Endpoint can be provided for Status Updates for [Uptime Kuma](https://github.com/louislam/uptime-kuma). Following env variables must be set:

    - KUMA_STATUS_ENDPOINT -- when provided will be called after an successfull backup
~~~Bash
S3_HASHDIR=DIR   #should be mounted - stores local checksum of pushed non-encrypted files (in S3 they are encrypted thus different checksum)
S3_OBJECT_STORAGE_EP=SITE_SPECIFIC_OBJECT_STORAGE EP (e.g  openstack.cebitec.uni-bielefeld.de:8080)
S3_ACCESS_KEY=SITE_SPECIFIC_ACCESS_KEY                
S3_SECRET_KEY=SITE_SPECIFIC_SECRET_KEY 
~~~
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
        - KUMA_STATUS_ENDPOINT
        - BACKUP_ROTATION_ENABLED=true
        - BACKUP_ROTATION_MAX_SIZE=10
        - BACKUP_ROTATION_CUT_SIZE=5
        - BACKUP_ROTATION_SIZE_TYPE=GiB
        - BACKUP_MAX_DAYS=21
        - S3_KUMA_STATUS_ENDPOINT 
        - S3_BACKUP_ENABLED=true
        - S3_PATH=limesurvey
        - S3_CONFIGS_DIR=~/configs
        - S3_ENCRYPT_PASSPHRASE=supersecretpassphrase
      networks:
        - portal
```

## Specific Images

### Postgresql
Needed environment variables:
~~~Bash
POSTGRES_HOST
POSTGRES_PORT
POSTGRES_USER
POSTGRES_DB            
POSTGRES_PASSWORD
~~~

### Mysql (Backups all Databases)
Needed environment variables:

~~~Bash
MYSQL_HOST
MYSQL_USER
MYSQL_PASSWORD
~~~

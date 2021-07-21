# Cron-Backup

Containered cron jobs based on an [Alpine Linux image](https://hub.docker.com/_/alpine). 

Depending on the specific backup usecase, the corresponding crontabs and scripts can be mounted in the container. For this, the following environment variables must be adjusted in the parent docker-compose.yml: 

* `BACKUP_OUTPUT_PATH`: Defines the path where the backup-folder of the container get's mounted on.
* `CRONTAB_FILE`: Defines the file in the repository where the cronjobs for the specific container are listed.
* `SCRIPTS_FOLDER`: Defines the folder in the repository, in which the scripts for the specific container are laying. 
* `PACKAGES_FILE`: Defines the package file in the repository, where all packages are listed which need to be installed via `apk add` for the specific use case of the container.

Specific containers may also needs other variables, which are listed below:

*Limesurvey Database Backup*   

* `LIMESURVEY_DB_PASSWORD`: Password to connect to the database in the corresponding container.

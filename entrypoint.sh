#!/bin/bash

declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

# Setup a cron schedule
echo "SHELL=/bin/bash
BASH_ENV=/container.env
* * * * * /run.sh &>/proc/1/fd/1
# This extra line makes it a valid cron" > mysqlcrons.txt

crontab mysqlcrons.txt
cron -f

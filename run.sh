#!/bin/bash
00 02 * * * /usr/bin/docker exec limesurvey_db sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /etc/test/

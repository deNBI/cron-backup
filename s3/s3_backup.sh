#!/bin/bash

# Backup directory specific
basedir="/etc/backup"
s3path=$S3_PATH


s3cmd mb s3://$S3_PATH
cd $basedir

if [ ! -d "$S3_HASHDIR" ]
then
        mkdir -p "$S3_HASHDIR"
fi

#Find all files within this directory and it's subdirs
find * -type f | while read -r a
do

        fnamehash=`echo "$a" | sha1sum | cut -d\  -f1`
        filehash=`sha1sum "$a" | cut -d\  -f1`
        source "$S3_HASHDIR/$fnamehash" 2> /dev/null

        if [ "$filehash" != "$storedhash" ]
        then
                s3cmd put -e $a s3://$S3_PATH/$a
                echo "storedhash='$filehash'" > "$S3_HASHDIR/$fnamehash"
        else
                # Hashes match, no need to push
                echo "$a unchanged, skipping......"
        fi

done
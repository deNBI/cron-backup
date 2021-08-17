#!/bin/sh

chmod +x /install-packages.sh
sh /install-packages.sh
chmod +x /etc/cronscripts/*
crontab /etc/crontabs/dockercron
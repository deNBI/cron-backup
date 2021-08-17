#!/bin/bash

chmod +x /install-packages.sh
/install-packages.sh
chmod +x /etc/cronscripts/*
crontab /etc/crontabs/dockercron
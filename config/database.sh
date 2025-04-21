#!/usr/bin/env bash
set -e

##################################################
#   PG_DUMP
##################################################
apt-get update && apt-get install -y lsb-release wget gnupg2 
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' 
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > /usr/share/keyrings/postgresql-archive-keyring.gpg 
echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list 
apt-get update && apt-get install -y postgresql-client

##################################################
#   CLEAN UP                                      
##################################################
apt-get purge -y --auto-remove && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*
#!/usr/bin/env bash
set -e

##################################################
#          Install Caché ODBC Client             #
##################################################

# Skip install if M1 Apple Silicon architecture
if [ $(uname -m) = "aarch64" ] ; then exit 0; fi    

# Extra packages
apt update && apt install -y unixodbc unixodbc-dev libodbccr2 odbcinst
docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr
install-php-extensions pdo odbc pdo_odbc

# Prepare ODBC Caché driver
mkdir -p /usr/local/cache/2018
tar xvzf /tmp/extra/cache/ODBC-2018.1.7.721.0-lnxubuntux64.tar.gz -C /usr/local/cache/2018
mv /tmp/extra/cache/odbc.ini /etc/odbc.ini

# Install Caché Driver
cd /usr/local/cache/2018 && ./ODBCinstall 
odbcinst -i -s -f /etc/odbc.ini 

# Binds
ln -s /usr/lib/x86_64-linux-gnu/libodbccr.so.2.0.0 /usr/lib/libodbccr.so

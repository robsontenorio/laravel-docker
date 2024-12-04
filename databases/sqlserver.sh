#!/usr/bin/env bash
set -e

##################################################
#   SQLSERVER DRIVERS + TOOLS                    #
##################################################

apt install -y php8.4-dev unixodbc-dev

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
apt update
ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18

pecl channel-update pecl.php.net
pecl install sqlsrv pdo_sqlsrv
printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.4/mods-available/sqlsrv.ini
printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.4/mods-available/pdo_sqlsrv.ini
phpenmod sqlsrv pdo_sqlsrv

apt purge php8.4-dev -y && apt-get autoremove -y
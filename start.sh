#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE}

echo -e " 

*********************************************************************************

==> Starting \"robsontenorio/laravel\" image for CONTAINER_ROLE = \"$role\" ...

  APP (default)    => App webserver (nginx + php-fpm).
  JOBS             => Queued jobs + scheduled commands (schedule:run).
  ALL              => APP + JOBS

*********************************************************************************

"
cd /etc/supervisor/conf.d-temp

if [ "$role" = "APP" ]; then
    cp nginx.conf ../conf.d/nginx.conf
    cp php-fpm.conf ../conf.d/php-fpm.conf
elif [ "$role" = "JOBS" ]; then    
    cp php-fpm.conf ../conf.d/php-fpm.conf
    cp jobs.conf ../conf.d/jobs.conf
elif [ "$role" = "ALL" ]; then
    cp nginx.conf ../conf.d/nginx.conf
    cp php-fpm.conf ../conf.d/php-fpm.conf
    cp jobs.conf ../conf.d/jobs.conf
fi

supervisord -c /etc/supervisord.conf
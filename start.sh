#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE}

echo -e " 

*********************************************************************************

==> Starting \"tjdft/laravel\" image for CONTAINER_ROLE = \"$role\" ...

  APP (default)    => App webserver (nginx + php-fpm).
  WORKER           => Process queues (queue:worker).
  SCHEDULER        => Run scheduled jobs   (schedule:run).
  ALL              => All previous services combined into a single container. 

*********************************************************************************

"
cd /etc/supervisor/conf.d-temp

if [ "$role" = "APP" ]; then
    cp nginx.conf ../conf.d/nginx.conf
    cp php-fpm.conf ../conf.d/php-fpm.conf
elif [ "$role" = "WORKER" ]; then
    cp php-fpm.conf ../conf.d/php-fpm.conf
    cp worker.conf ../conf.d/worker.conf
elif [ "$role" = "SCHEDULER" ]; then    
    cp php-fpm.conf ../conf.d/php-fpm.conf
    cp scheduler.conf ../conf.d/scheduler.conf
elif [ "$role" = "ALL" ]; then
    cp *.conf ../conf.d/
   
fi

supervisord
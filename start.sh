#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE}

echo -e " 

*********************************************************************************

==> Starting \"robsontenorio/laravel\" image for CONTAINER_ROLE = \"$role\" ...

  APP (default)    => App webserver (nginx + octane).
  JOBS             => Queued jobs + scheduled commands (schedule:run).
  ALL              => APP + JOBS

*********************************************************************************

"
cd /etc/supervisor/conf.d-temp

# Production settings
cp octane.conf ../conf.d/octane.conf

# Dev mode settings
if [ "$DEV_MODE" = "TRUE" ]; then
cp octane-dev.conf ../conf.d/octane.conf
fi

# Define container role
if [ "$role" = "APP" ]; then
    cp nginx.conf ../conf.d/nginx.conf
elif [ "$role" = "JOBS" ]; then
    cp jobs.conf ../conf.d/jobs.conf
elif [ "$role" = "ALL" ]; then
    cp nginx.conf ../conf.d/nginx.conf
    cp jobs.conf ../conf.d/jobs.conf
fi

supervisord -c /etc/supervisord.conf
#!/usr/bin/zsh

# Laravel Scheduler
php artisan schedule:work > /dev/null 2>&1 &

# Laravel Horizon
if [ -f "artisan" ] && php artisan | grep -q "horizon:"; then
    php artisan horizon > /dev/null 2>&1 &
else
  echo $'\e[43;97m Skiping Horizon worker. If you want to use Horizon, make sure to restart the container after installing it. \e[0m' >&2
fi

# Start FrankenPHP
frankenphp run --config /etc/caddy/Caddyfile
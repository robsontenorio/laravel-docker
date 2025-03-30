#!/usr/bin/zsh

error_msg() {
  echo "\033[41;37m[ERROR] $1\033[0m\n"
}

if [ ! -d "vendor/laravel/octane" ]; then
  error_msg "Laravel Octane is not installed. Access the container, install it then rebuild."
  exec frankenphp run /etc/caddy/Caddyfile
else
  php artisan octane:start
fi
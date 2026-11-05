#!/usr/bin/zsh

export FORCE_COLOR=1

warning_msg() {
  echo "\n\e[43;97m Warning \e[0m $1\n" >&2
}

success_msg() {
  echo "\n\e[42;97m Success \e[0m $1\n" >&2
}

info_msg() {
  echo "\n\e[44;97m Info \e[0m $1\n" >&2
}

# Run deployment script
if [ "$RUN_DEPLOY" = "true" ] && [ -f "/var/www/html/.docker/deploy.sh" ]; then
    info_msg "🚀  Deployment script ........................................"
    /bin/sh /var/www/html/.docker/deploy.sh
    info_msg "🚀  Done! ...................................................."
fi


# Laravel Scheduler
if [ "$RUN_DEPLOY" = "true" ] && [ -d "vendor/laravel" ]; then
    php artisan schedule:work > /dev/null 2>&1 &
    success_msg "Laravel Scheduler started."
else
  warning_msg "Skiping Laravel Scheduler. Start it on localhost with: php artisan schedule:work"
fi


# Laravel Horizon
if [ -d "vendor/laravel/horizon" ]; then
    php artisan horizon > /dev/null 2>&1 &
    success_msg "Laravel Horizon started."
else
  warning_msg "Skiping Laravel Horizon. If you want to use Horizon, make sure to restart the container after installing it."
fi

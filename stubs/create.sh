#!/usr/bin/zsh

printf "\n\nCreating ${APP_NAME} ...\n\n"

composer create-project laravel/laravel example-app         # new laravel project on folder "example-app"
mv example-app/*(DN) .                                      # move that fold to root directory
rm -rf example-app/                                         # Remove folder
composer require laravel/octane                             # require octane dependency
php artisan octane:install --server=swoole                  # install octane with swoole
yarn install                                                # install JS dependencies
yarn add --dev chokidar                                     # required to watch files with octane

# TODO: how to make it simple?
# Replace some variables 
mv .env.example /tmp/.env.example        
sed -i "s/APP_NAME=Laravel/APP_NAME=${APP_NAME}/" /tmp/.env.example
sed -i "s/APP_DEBUG=true/APP_DEBUG=false/" /tmp/.env.example
sed -i "s/APP_ENV=local/APP_ENV=production/" /tmp/.env.example
sed -i "s/BROADCAST_DRIVER=log/BROADCAST_DRIVER=redis/" /tmp/.env.example
sed -i "s/CACHE_DRIVER=file/CACHE_DRIVER=redis/" /tmp/.env.example
sed -i "s/QUEUE_CONNECTION=sync/QUEUE_CONNECTION=redis/" /tmp/.env.example
sed -i "s/SESSION_DRIVER=file/SESSION_DRIVER=redis/" /tmp/.env.example
sed -i "s/REDIS_HOST=127.0.0.1/REDIS_HOST=${APP_NAME}-redis/" /tmp/.env.example
sed -i "s/DB_CONNECTION=mysql/DB_CONNECTION=pgsql/" /tmp/.env.example
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=${APP_NAME}-postgres/" /tmp/.env.example
sed -i "s/DB_PORT=3306/DB_PORT=5432/" /tmp/.env.example
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=${APP_NAME}/" /tmp/.env.example
sed -i "s/DB_USERNAME=root/DB_USERNAME=${APP_NAME}/" /tmp/.env.example
sed -i "s/DB_PASSWORD=/DB_PASSWORD=${APP_NAME}/" /tmp/.env.example
mv  /tmp/.env.example .env.example
cat .env.example > .env
php artisan key:generate
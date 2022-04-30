#!/usr/bin/env bash
set -e

git clone -b octane --single-branch https://github.com/robsontenorio/laravel-docker.git

read -p "App name: " app_name

mkdir $app_name
cp -r "laravel-docker/stubs/." $app_name
rm -rf laravel-docker/

dockercompose="$app_name/.docker/docker-compose.yml"
devcontainer="$app_name/.devcontainer/devcontainer.json"

sed -i '' "s/{{APP_NAME}}/$app_name/" $dockercompose
sed -i '' "s/{{APP_NAME}}/$app_name/" $devcontainer

# Sping up new laravel project (if it does not exist).
if [ ! -f composer.json ]
then
    echo "Creating a new Laravel project ..."
    docker run --rm -v "$(pwd)":/var/www/app robsontenorio/laravel:octane zsh -c "create.sh"
fi
#!/usr/bin/env bash
set -e

git clone -b octane --single-branch https://github.com/robsontenorio/laravel-docker.git

read -p "App name: " app_name

mkdir $app_name
cp -r "laravel-docker/stubs/." $app_name
rm -rf laravel-docker/

sed -i '' "s/{{APP_NAME}}/$app_name/" "$app_name/.docker/docker-compose.yml"
sed -i '' "s/{{APP_NAME}}/$app_name/" "$app_name/.devcontainer/devcontainer.json"

chmod a+x "$app_name/create.sh"

# Sping up new laravel project (if it does not exist).
if [ ! -f composer.json ]
then
    echo "Creating a new Laravel project ..."
    docker run --rm -v "$(pwd)/$app_name":/var/www/app robsontenorio/laravel:octane sh -c "/var/www/app/create.sh"
    echo "==> Done! Open this project on VSCode with remote containers extension."
fi
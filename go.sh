#!/usr/bin/zsh

git clone -b octane --single-branch https://github.com/robsontenorio/laravel-docker.git

printf "\n\n"
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
    printf "\n\nCreating a new Laravel project ...\n\n"
    docker run --rm -v "$(pwd)/$app_name":/var/www/app robsontenorio/laravel:octane zsh -c "APP_NAME=$app_name /var/www/app/create.sh"
    rm "$app_name/create.sh"
    printf "\n\n\n\n==> Done! Open this project on VSCode with remote containers extension."
fi
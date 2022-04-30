#!/usr/bin/env bash
set -e

git clone -b octane --single-branch https://github.com/robsontenorio/laravel-docker.git

read -p "App name: " app_name

mkdir $app_name
cp -r "laravel-docker/stubs/." $app_name

dockercompose="$app_name/.docker/docker-compose.yml"
devcontainer="$app_name/.devcontainer/devcontainer.json"

sed -i '' "s/{{APP_NAME}}/$app_name/" $dockercompose
sed -i '' "s/{{APP_NAME}}/$app_name/" $devcontainer

touch "readme.txt"
echo "Open this folder on VSCODE with Remote Container extension. The are hidden folders." >> "$app_name/readme.txt"
echo "==> Done! Open this project on VSCODE with Remote Container extension."

# rm -rf laravel-docker/
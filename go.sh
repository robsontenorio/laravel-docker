#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo $SCRIPT_DIR
read -p "App name: " app_name

mkdir $app_name
cp -r "${SCRIPT_DIR}/stubs/." $app_name

dockercompose="$app_name/.docker/docker-compose.yml"
devcontainer="$app_name/.devcontainer/devcontainer.json"

sed -i '' "s/{{APP_NAME}}/$app_name/" $dockercompose
sed -i '' "s/{{APP_NAME}}/$app_name/" $devcontainer

echo "==> Done! Open this project on VSCODE with Remote Container extension."
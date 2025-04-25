<p align="center">
  <img src="https://raw.githubusercontent.com/robsontenorio/laravel-docker/refs/heads/franken/octopus.png" height="128">
</p> 
<p align="center">    
  <a href="https://hub.docker.com/r/robsontenorio/laravel">
    <img src="https://img.shields.io/docker/pulls/robsontenorio/laravel?color=orange&style=for-the-badge" />
    <img src="https://img.shields.io/docker/image-size/robsontenorio/laravel?sort=date&style=for-the-badge" />
  </a>
</p>

# Laravel Docker with FrankenPHP

Production-ready Laravel image powered by **FrankenPHP**.

## Features

- Laravel Octane support.
- Schedule worker.
- Laravel Horizon worker.
- PostgreSQL / MySQL drivers and cli tools.
- Common PHP extensions.
- Composer / Node / Yarn / NPM.
- OhMyZSH terminal.

## Important


💢 After installing **Laravel Octane** or **Laravel Horizon** , for the first time, you must restart the container. 

💢 The restart is necessary because these processes are initiated through the `start.sh` script.

💢 You can monitor the image startup progress by checking the container logs.

## Usage

### Structure
```bash
|
|_ .docker/
|  |_ Dockerfile
|  |_ docker-compose.yml
|  |_ deploy.sh
|
|_ <your app>
```

### Dockerfile

```Dockerfile
# On `base` stage, CMD is not required
# The default is CMD ["--max-requests=1"]
# It will execute `php artisan octane:start --max-requests=1`
# For the `production` stage, you may want to customize these params.


FROM robsontenorio/laravel:franken AS base
COPY --chown=appuser:appuser . .


FROM base AS production
ENV RUN_DEPLOY=true                              
CMD ["--max-requests=500", "--log-level=info"]   
```

### docker-compose.yml
```yaml
# Local development configuration.
# The `target` refers to the `base` stage defined in the `Dockerfile` above.
# So, the `production` stage will not be executed.


services:
  my-app:
    build:
      context: ..
      dockerfile: .docker/Dockerfile
      target: base  
      volumes:
      - ../:/app:cached
    ports:
      - 8000:8000
```

### deploy.sh
```bash
#!/usr/bin/zsh

# This script runs when `ENV RUN_DEPLOY=true`
# Use it only for production

echo '------ Starting deploy  ------'

cp .env.example .env
composer install --prefer-dist --no-interaction --no-progress --ansi

yarn install
yarn build

php artisan migrate --seed --force

php artisan storage:link
php artisan optimize

echo '------ Deploy completed ------'
```


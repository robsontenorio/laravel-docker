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

This image automatically detects if your application is using Laravel Octane and:
- Starts in `worker` mode when Octane is present.
- Falls back to `classic` mode otherwise.

Also included:
- Schedule worker.
- Laravel Horizon worker.
- PostgreSQL and MySQL drivers + cli tools.
- Common PHP extensions.

## Usage

**Structure**
```bash
|
|_ .docker/
|  |_ Dockerfile
|  |_ docker-compose.yml
|  |_ deploy.sh
|
|_ <your app>
```

**Dockerfile**

```Dockerfile
FROM robsontenorio/laravel:franken AS base
COPY --chown=appuser:appuser . .
# CMD ["--max-requests=1"] This is the default, you can remove this line.

FROM base AS production
ENV RUN_DEPLOY=true                               # Triggers `deploy.sh` execution.
CMD ["--max-requests=500", "--log-level=info"]    # Pass extra parameters for Octane.
```

**docker-compose.yml** 
```yaml
# For local development vnvironment only

services:
    my-app:
        build:
            context: ..
            dockerfile: .docker/Dockerfile
            target: base   # <-- Use the `base` stage for local development
            volumes:
            - ../:/app:cached
        ports:
            - 8000:8000
```

**deploy.sh**
```bash
#!/usr/bin/zsh

# This script is intended to run during production deployment. See `Dockerfile`

echo '------ Starting deploy tasks  ------'

cp .env.example .env
composer install --prefer-dist --no-interaction --no-progress --ansi

yarn install
yarn build

php artisan migrate --seed --force

php artisan storage:link
php artisan optimize

echo '------ Deploy completed ------'
```


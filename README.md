<p align="center">
  <img src="https://raw.githubusercontent.com/robsontenorio/laravel-docker/octane/octopus.png">
</p> 
<p align="center">    
  <a href="https://hub.docker.com/r/robsontenorio/laravel">
    <img src="https://img.shields.io/docker/pulls/robsontenorio/laravel?color=orange&style=for-the-badge" />
    <img src="https://img.shields.io/docker/image-size/robsontenorio/laravel?sort=date&style=for-the-badge" />
  </a>
</p>

# WIP - Laravel Docker (Octane)

Laravel Octane production ready image using **FrankenPHP**. 

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
# Base image
FROM robsontenorio/laravel:franken AS base
COPY . .

# Development
# The `--max-requests=1` makes Octane do not cache the code.  
# The `--log-level` is optional
FROM base AS local
CMD php artisan octane:frankenphp --max-requests=1 --log-level=info || start

# Production
FROM base AS deploy
CMD ["/bin/sh", "-c", ".docker/deploy.sh"]
```

**.docker/deploy.sh**
```bash
#!/usr/bin/zsh

echo '------ Starting deploy tasks  ------'

cp .env.example .env
composer install --prefer-dist --no-interaction --no-progress --ansi

yarn install
yarn build

php artisan migrate --seed --force
php artisan storage:link
php artisan optimize
php artisan octane:frankenphp --log-level=warning

echo '------ Deploy completed ------'
```


**docker-compose.yml** (for local development only)
```yaml
services:
  app:
    build:
      context: ..
      dockerfile: .docker/Dockerfile
      target: local   # <-- runs the `local` stage instead of `deploy`.
    volumes:
      - ../:/app
    ports:
      - 8000:8000
```

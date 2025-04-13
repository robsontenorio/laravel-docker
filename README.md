<p align="center">
  <img src="https://raw.githubusercontent.com/robsontenorio/laravel-docker/octane/octopus.png">
</p> 
<p align="center">    
  <a href="https://hub.docker.com/r/robsontenorio/laravel">
    <img src="https://img.shields.io/docker/pulls/robsontenorio/laravel?color=orange&style=for-the-badge" />
    <img src="https://img.shields.io/docker/image-size/robsontenorio/laravel?sort=date&style=for-the-badge" />
  </a>
</p>

# WIP - Laravel Docker (FrankenPHP)

Laravel production ready image using **FrankenPHP in classic mode**. 

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
# Base
FROM robsontenorio/laravel:franken-classic AS base
COPY --chown=appuser:appuser . .

# Production
FROM base AS deploy
RUN chmod a+x .docker/deploy.sh
CMD ["/bin/sh", "-c", ".docker/deploy.sh && start"]
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

echo '------ Deploy completed ------'
```


**docker-compose.yml** (for local development only)
```yaml
services:
    my-app:
        build:
            context: ..
            dockerfile: .docker/Dockerfile
            target: base
        environment:
            - SERVER_NAME=:8217
        tty: true
        volumes:
            - ../:/app:cached
        ports:
            - 8217:8217            
```

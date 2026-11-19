<p align="center">
  <img src="https://raw.githubusercontent.com/robsontenorio/laravel-docker/master/up.png">
</p> 
<p align="center">    
  <a href="https://hub.docker.com/r/robsontenorio/laravel">
    <img src="https://img.shields.io/docker/v/robsontenorio/laravel?color=green&sort=date" />
    <img src="https://img.shields.io/docker/pulls/robsontenorio/laravel?color=orange" />
    <img src="https://img.shields.io/docker/image-size/robsontenorio/laravel?sort=date" />
  </a>
</p>

## Laravel Docker Image

🐘 This is an **opinionated** wrapper around [serverside/up](https://serversideup.net/open-source/docker-php/). 

🐘 Make sure to check the [Dockerfile](Dockerfile).

🐘 For settings and environment variables, see the original image docs.

## Usage 

**Structure**

```bash
  |
  |__ .docker/
  |  |__ compose.yaml
  |  |__ Dockerfile
  |  |__ deploy.sh       #  Deploy script
  |
  |__ app/
  |__ bootstrap/
  |__ config/
  |__ ...
    

```

**compose.yaml**

```yaml
services:
  app:
    build:
      target: base
      context: ..
      dockerfile: .docker/Dockerfile      
    volumes:
      - ../:/var/www/html:cached
    ports:
      - "8080:8080"
```

**Dockerfile**

```Dockerfile
# Base 
FROM robsontenorio/laravel AS base
COPY --chown=www-data:www-data . .

# Build
FROM base AS build
RUN cp .env.example .env
RUN composer install --prefer-dist --no-interaction --no-progress --quiet --ansi --no-dev
RUN yarn install --silent && yarn build && yarn cache clean && rm -rf node_modules

# Production
FROM build AS production
ENV RUN_DEPLOY=true
```

**deploy.sh**

```bash
#!/usr/bin/zsh

php artisan migrate --seed --force
php artisan storage:link
php artisan optimize
```
<div align="center">
    <img src="octopus.png">
</div>

# Laravel Docker Image

It provides a flexible strategy to assign roles to specific containers by re-using same image.

When handling massive amount of process the best option is to split into multiple containers. This way, each container has a specific role on servers and you can scale it independently.

## Features

- Nginx
- PHP
    - FPM and common extensions
    - Composer
    - Laravel Installer    
- Node
    - Yarn
    - Npm
- Database drivers
    - Mysql 
    - Postgres 
    - Sqlite
- Supervisor
   - All services are started through `supervisord`
- Extra
   - Zsh
   - Git
   - And more ...

## Container role

Assign specific role to a container.
**Laravel Horizon is mandatory for JOB or ALL roles.**


| Value             | Description |
| ---------------   | ----------- |
| APP *(default)*   | App webserver (nginx + php-fpm).   
| JOBS              | Queued jobs + scheduled commands. 
| ALL               | All in one. 

### Optional

| Key                         | Description |
| --------------------------- | ----------- |
| GITHUB_OAUTH_KEY            | Needed due to github rate limit |


## Local development

When you need to handle queued jobs and scheduled commands set `CONTAINER_ROLE=ALL`

```yaml
# docker-compose.yml

services:
  app:
    image: robsontenorio/laravel    
    environment:
      - CONTAINER_ROLE=ALL
    volumes:
      - .:/var/www/html
    ports:
      - 8080:8080

    # Other services  here like mysql, redis ...
```

If you **DO NOT** need to handle any queued jobs or scheduled commands use this.
As default is `CONTAINER_ROLE=APP` nothing need to be set. 

```yaml
# docker-compose.yml

services:
  app:
    image: robsontenorio/laravel     
    volumes:
      - .:/var/www/html
    ports:
      - 8080:8080

    # Other services here like mysql, redis ...
```


Split into multiple containers for large scale apps.

```yaml
# docker-compose.yml

services:
  app:
    image: robsontenorio/laravel
    environment:
        - CONTAINER_ROLE=APP
    volumes:
      - .:/var/www/html
    ports:
      - 8080:8080

  jobs:
    image: robsontenorio/laravel
    environment:
        - CONTAINER_ROLE=JOBS
    volumes:
      - .:/var/www/html

 # Other services like mysql, redis ...
```


## Production

This only applies if your deployment platform is based on docker. 

This image relies on `/usr/local/bin/start`  script to bootstrap all services.

Consider this setup.

```bash
 .docker/
    |__ deploy.sh           # production only
    |__ Dockerfile          # production only
    |__ docker-compose.yml  # development only

  app/
   |__ ...
```

A good idea is to have a `deploy.sh` script to run any aditional commands before container startup on target deployment platform.

```bash
#!/bin/sh
set -e

echo 'Starting deployment tasks ...'

php artisan config:cache
php artisan migrate --seed --force

# more commands ...

echo 'Done!'
```

So, on `Dockerfile`

```dockerfile
FROM robsontenorio/laravel

COPY . .
RUN chmod a+x .docker/deploy.sh

# Run deployment tasks before start services
CMD ["/bin/sh", "-c", ".docker/deploy.sh && /usr/local/bin/start"] 
```

### Container role

It really depends on platform you will deploy. All you need is to set an environment variable to container.

- CONTAINER_ROLE=APP (default, no need to set)
- CONTAINER_ROLE=JOBS
- CONTAINER_ROLE=ALL

## Gitlab example

```yaml
image: robsontenorio/laravel  # <--- Will be used in all steps

stages:
  - build
  - test
  - deploy

# Install PHP dependencies
composer:  
  stage: build
  ...

# Install JS dependencies
yarn:  
  stage: build  
  ...

# PHP tests
phpunit:  
  stage: test
  dependencies:
    - composer
    - yarn    
  ...


# Build production final docker image and deploy it (optional)
production:
   stage: deploy
   image: docker:latest
   only:
    - tags
   script:
    - docker login <credentials>
    - docker build <path to Dockerfile>
    - docker push <to some registry>
```
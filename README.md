<div align="center">
    <img src="octopus.png">
</div>

# Multi-purpose Laravel Docker Image

When running services through separated containers you must keep same application codebase for each one. Instead of building a specific image for each service, why not a single flexible image that uses same app codebase?


## Versions

| Image Tag           | Description     |
| ------------------- | --------------- |
|  1.0                | PHP 7.4.3, Node 12

## Features

- Non-root user. 
    - This image runs as `appuser`.
    - Default workdir `/var/www/app`
- Supervisor
    - All major services are started through `supervisord`
- PHP
    - Php-fpm
    - Extensions bundle
    - Composer
    - Prestissimo
    - Laravel Installer    
    - Laravel Dusk support (Chromium)
- Nginx
- Node
    - Yarn
    - Npm
- Database drivers
    - Mysql
    - Postgres
    - Sqlite
    - Oracle 12c
    - Intersystem Cachè

## Environment variables

### CONTAINER_ROLE

Manages role assigned to each container.

| Value           | Description |
| --------------- | ----------- |
| APP (default)   | App webserver (nginx + php-fpm).        
| WORKER          | Process the queues (queue:worker).        
| SCHEDULER       | Run scheduled jobs   (schedule:run).        
| ALL             | All previous services combined into a single container. 


### Others

| Key                         | Description |
| --------------------------- | ----------- |
| GITHUB_OAUTH_KEY            | Recommended by Prestissimo (optional)


## Usage samples

If you **DO NOT** need to handle any jobs or queues.

```yaml
# docker-compose.yml

version: "3"

services:
  ######## APP ########
  app:
    image: tjdft/laravel    
    environment:
      - CONTAINER_ROLE=APP
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

    # Other services like mysql, redis ...
```

When you need to handle jobs and queues, for simple apps. 

```yaml
# docker-compose.yml

version: "3"

services:
  ######## APP ########
  app:
    image: tjdft/laravel    
    environment:
      - CONTAINER_ROLE=ALL
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

    # Other services like mysql, redis ...
```

Split into multiple containers for large scale apps.

```yaml
# docker-compose.yml

version: "3"

services:
  ######## APP ########
  app:
    image: tjdft/laravel
    environment:
        - CONTAINER_ROLE=APP
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

 ######## WORKER ########
  scheduler:
    image: tjdft/laravel
    environment:
        - CONTAINER_ROLE=WORKER
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

######## SCHEDULER ########
  worker:
    image: tjdft/laravel
    environment:
        - CONTAINER_ROLE=SCHEDULER
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

 # Other services like mysql, redis ...
```

## Split into services?

When handling massive amount of process the best option is to split into multiple services. As this is image keep same app codebase for application, each container has a specific role on servers. This way you can scale it independently:

- Webserver will be managed by `CONTAINER_ROLE=APP`
- Scheduled jobs by `CONTAINER_ROLE=SCHEDULER`
- Queues by `CONTAINER_ROLE=WORKER`

## Extending this image

This image relies on `/usr/local/bin/start` script to bootstrap all services. If you need to run additional commands on container startup make sure to combine both.

> TIP: see `start.sh`

`deploy.sh`
```bash
#!/bin/sh
set -e

echo '------ Start deploy tasks  ------'

php artisan migrate --force
php artisan config:cache
# more ...

echo '------ Deploy completed ------'
```
`Dockerfile`
```dockerfile
FROM tjdft/laravel

COPY --chown=appuser:appuser . .

RUN chmod a+x .docker/deploy.sh

CMD ["/bin/sh", "-c", ".docker/deploy.sh && /usr/local/bin/start"] 
```

`docker-compose.yml`
```yml
services:
  ######## APP ########
  laravel:
    build:
      context: ..
      dockerfile: .docker/laravel/Dockerfile
    volumes:
      - ../:/var/www/app:cached
    # Will override "CMD" instruction from Dockerfile
    # No need to execute deploy task while developing
    command: "/usr/local/bin/start"    
```

## Overriding settings

Supervisor programs settings must be placed on `/etc/supervisor/conf.d/*` . While general supervisor settings must be placed on `/etc/supervisord.conf` 
 
```Dockerfile
FROM tjdft/laravel

# override supervisord 
COPY my-supervisord.conf /tmp/supervisor/supervisord.conf 

# override specif program
COPY my-laravel-worker.conf /tmp/supervisor/conf.d/laravel-worker.conf 

```

For other services like `nginx` and `php-fpm` you must place files on default paths like `/etc/nginx/nginx.conf`.

```Dockerfile
FROM tjdft/laravel

COPY my-nginx.conf /etc/nginx/nginx.conf
```
> Tip: see folder `config/*`

## TODO

- [ ] Override php-fpm settings
- [ ] Make Oracle/Cachè optional

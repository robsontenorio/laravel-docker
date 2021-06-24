<div align="center">
    <img src="octopus.png">
</div>

# Multi-purpose Laravel Docker Image

When running services through separated containers you must keep same application codebase for each one. Instead of building a specific image for each service, why not a single flexible image that uses same app codebase?

## Features

- Non-root user. 
    - This image runs as `appuser`.
    - Default workdir `/var/www/app`
- Supervisor
    - All services are started through `supervisord`
- PHP
    - FPM    
    - Commom extensions
    - Composer
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
    - Oracle (12c)
    - Intersystem Cachè (2018)

## Environment variables

### CONTAINER_ROLE

Manages role assigned to each container.

| Value           | Description |
| --------------- | ----------- |
| APP (default)   | App webserver (nginx + php-fpm).   
| JOBS            | Queued jobs + scheduled commands. 
| ALL             | APP + JOBS

**NOTE: Laravel Horizon mandatory for jobs.**

### Others

| Key                         | Description |
| --------------------------- | ----------- |
| GITHUB_OAUTH_KEY            | Needed due to github rate limit |


## Usage samples

If you **DO NOT** need to handle any queued jobs or scheduled commands use this.
As default is `CONTAINER_ROLE=APP` nothing need to be set. 

```yaml
# docker-compose.yml

version: "3"

services:
  ######## APP ########
  app:
    image: nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]     
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

    # Other services like mysql, redis ...
```

When you need to handle queued jobs and scheduled commands, for simple apps. Set `CONTAINER_ROLE=ALL`

```yaml
# docker-compose.yml

version: "3"

services:
  ######## APP ########
  app:
    image: nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]    
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
    image: nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]
    environment:
        - CONTAINER_ROLE=APP
    volumes:
      - .:/var/www/app:cached      
    ports:
      - 8080:8080

 ######## JOBS ########
  jobs:
    image: nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]
    environment:
        - CONTAINER_ROLE=JOBS
    volumes:
      - .:/var/www/app:cached      

 # Other services like mysql, redis ...
```

## Split into services?

When handling massive amount of process the best option is to split into multiple services. As this is image keep same app codebase for application, each container has a specific role on servers. This way you can scale it independently:

- Webserver will be managed by `CONTAINER_ROLE=APP`
- Queued jobs and scheduled commands by `CONTAINER_ROLE=JOBS`

## Extended example

This image relies on `/usr/local/bin/start`  script to bootstrap all services (see `start.sh`). If you need to run additional commands on container startup make sure to combine with a extra script.

1. Consider this setup

``` 
 .docker/
    |__ deploy.sh
    |__ docker-compose.yml
    |__ Dockerfile

  app/
   |__ ...
```

1. A good idea is to have a `deploy.sh` script. 

```bash
#!/bin/sh
set -e

echo '------ Start deploy tasks  ------'

php artisan config:cache
# more ...

echo '------ Deploy completed ------'
```

2. On `Dockerfile`

```dockerfile
FROM nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]

# Set owner when coping
COPY --chown=appuser:appuser . .

# Set execution permission
RUN chmod a+x .docker/deploy.sh

# When container starts will run both commands
CMD ["/bin/sh", "-c", ".docker/deploy.sh && /usr/local/bin/start"] 
```

3. On `docker-compose.yml`.

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
    # No need to execute deploy task while developing locally
    command: "/usr/local/bin/start"    
```

## Overriding default settings

Supervisor programs settings must be placed on `/etc/supervisor/conf.d/*` . While general supervisor settings must be placed on `/etc/supervisord.conf` 
 
```Dockerfile
FROM nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]

# override supervisord 
COPY my-supervisord.conf /tmp/supervisor/supervisord.conf 

# override specif program
COPY my-laravel-job.conf /tmp/supervisor/conf.d/jobs.conf 

```

For other services like `nginx` and `php-fpm` you must place files on default paths like `/etc/nginx/nginx.conf`.

```Dockerfile
FROM nexuspull.tjdft.jus.br/tjdft/laravel:[TAG_NUMBER]

COPY my-nginx.conf /etc/nginx/nginx.conf
```
> Tip: see folder `config/*`

## TODO

- [ ] Override php-fpm settings
- [ ] Make Oracle/Cachè optional

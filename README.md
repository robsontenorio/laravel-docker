<p align="center">
  <img src="https://raw.githubusercontent.com/robsontenorio/laravel-docker/master/octopus.png">
</p> 
<p align="center">    
  <a href="https://hub.docker.com/r/robsontenorio/laravel">
    <img src="https://img.shields.io/docker/v/robsontenorio/laravel?color=green&sort=semver&style=for-the-badge" />
    <img src="https://img.shields.io/docker/pulls/robsontenorio/laravel?color=orange&style=for-the-badge" />
    <img src="https://img.shields.io/docker/image-size/robsontenorio/laravel?sort=date&style=for-the-badge" />
  </a>
</p>

# Laravel Docker Image (Swoole + Octane)

It provides a flexible strategy to assign roles to specific containers by re-using same image.

When handling massive amount of process the best option is to split into multiple containers. This way, each container has a specific role on servers and you can scale independently.

## Quick start

1. Run!
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robsontenorio/laravel-docker/octane/go.sh)"

```
1. Choose project name.
1. Wait install all dependencies.
1. Open in VSCODE (with Remote Container extension).
1. **Done!** Go to http://localhost:8017

## What?

On first run at VSCODE remote containers it will install a fresh new Laravel project (octane + postgres + redis) with following structure.

```bash
|
.devcontainer/
|   |__ devcontainer.json  
|    
.docker/
|  |__ deploy.sh           
|  |__ Dockerfile          
|  |__ docker-compose.yml  
|
|
... a fresh laravel app here


```



## Features

- Nginx
- PHP
    - Swoole (Laravel Octane) and common extensions
    - Composer
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

| Value             | Description |  Requirements |
| ---------------   | ----------- | ------------- |
| APP *(default)*   | octane + nginx  | `laravel/octane` package |
| JOBS              | octane + horizon | `laravel/horizon` package |
| ALL               | octane + horizon + nginx | `laravel/octane` + `laravel/horizon`

:warning: Laravel Horizon is mandatory for "JOB" or "ALL" roles. 
 After install `laravel/horizon` package rebuild containers.


###  All in same container.

```yaml
# docker-compose.yml

services:  
  app:
    image: robsontenorio/laravel:octane    
    environment:
      - CONTAINER_ROLE=ALL    # <---- nginx + octane + horizon 
    volumes:
      - .:/var/www/app
    ports:
      - 8017:8080

    # Other services ...
```


### Split into multiple containers.

```yaml
# docker-compose.yml

services:
  app:
    image: robsontenorio/laravel:octane
    environment:
        - CONTAINER_ROLE=APP   # <---- octane + nginx
    volumes:
      - .:/var/www/app
    ports:
      - 8017:8080  
  jobs:
    image: robsontenorio/laravel
    environment:
        - CONTAINER_ROLE=JOBS  # <---- octane + horizon 
    volumes:
      - .:/var/www/app

 # Other services like mysql, redis ...
```

## Local development

By default container is set to run in `production` and Octane will not watch for file changes.

While developing locally:
- Set build target to `local` (see Dockerifle)
- Set container environment var `DEV_MODE = true` (octane watch mode)
- And `yarn add --save-dev` to your project (octane watch mode)

```yaml
# docker-compose.yml

services:
  app:
    image: robsontenorio/laravel:octane
    build:
      context: ..
      dockerfile: .docker/Dockerfile
      target: local           # <---- LOCALLY ONLY (multi stage build).
    environment:
        - CONTAINER_ROLE=APP   
        - DEV_MODE=TRUE        # <---- LOCALLY ONLY (octane watch mode).
    volumes:
      - .:/var/www/app
    ports:
      - 8017:8080
```



## Production

A typical build for production look like this, considering current Dockerfile path is `.docker/Dockerfile`

```bash
docker build -t myapp:tag --target production --file .docker/Dockerfile . # <-- a dot "." here
```

## Gitlab example

```yaml
image: robsontenorio/laravel:octane  # <--- Will be used in all steps

stages:
  - build
  - test
  - deploy

# Install PHP dependencies
composer:  
  stage: build
  script:
    - ...

# Install JS dependencies
yarn:  
  stage: build  
  script:
    - ...

# PHP tests
phpunit:  
  stage: test
  dependencies:
    - composer
    - yarn    
  script:
    - ...


# Build production final docker image and deploy it (optional)
production:
   stage: deploy
   image: docker:latest
   only:
    - tags
   script:
    - docker login <credentials>
    - docker build <args>
    - docker push <to some registry>
```

## Cypress

Need e2e tests with Cypress? See [robsontenorio/laravel-docker-cypress](https://github.com/robsontenorio/laravel-docker-cypress)

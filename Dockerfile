FROM serversideup/php:8.5.0-fpm-nginx

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

ENV LANG="C.UTF-8"
ENV PHP_OPCACHE_ENABLE=1
ENV PHP_MEMORY_LIMIT=3072M
ENV PHP_UPLOAD_MAX_FILE_SIZE=300M
ENV PHP_POST_MAX_SIZE=300M
ENV PHP_FPM_PM_MAX_REQUESTS=500
ENV NGINX_ACCESS_LOG=/var/log/nginx/access.log
ENV NGINX_ERROR_LOG=/var/log/nginx/error.log

ARG UID=1000
ARG GID=1000

USER root

# Setup permissions
RUN docker-php-serversideup-set-id www-data $UID:$GID && \
    docker-php-serversideup-set-file-permissions --owner $UID:$GID --service nginx

# Basic packages
RUN apt update && \
    apt install -y \
        git \
        zsh \
        unzip \
        nano \
        micro \
        chromium \
        htop \
        btop \
        pass \
        default-mysql-client \
        postgresql-client

# Extensions
RUN install-php-extensions intl bcmath

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm

# Switch to www-data
USER www-data

# OhMyZsh
RUN zsh && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Laravel Installer
RUN composer global require laravel/installer && \
    composer clear-cache && \
    echo 'export PATH="$PATH:$COMPOSER_HOME/vendor/bin"' >> ~/.zshrc

# Startup script
COPY --chmod=755 start.sh /etc/entrypoint.d/00-start.sh
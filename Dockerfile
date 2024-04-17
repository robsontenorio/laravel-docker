FROM ubuntu:22.04

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

ENV TZ=UTC 
ENV LANG="C.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive 
ENV CONTAINER_ROLE=${CONTAINER_ROLE:-APP} 

WORKDIR /var/www/app

RUN apt update \
  # Add PHP 8.3 repository 
  && apt install -y software-properties-common && add-apt-repository ppa:ondrej/php \
  # PHP extensions
  && apt install -y \
  php8.3-bcmath \
  php8.3-cli \
  php8.3-curl \
  php8.3-fpm \
  php8.3-gd \
  php8.3-intl \
  php8.3-mbstring  \
  php8.3-mysql \
  php8.3-redis \
  php8.3-sockets \
  php8.3-sqlite3 \
  php8.3-pcov \
  php8.3-pgsql \
  php8.3-opcache \
  php8.3-xml \
  php8.3-zip \
  # Extra
  curl \
  git \
  htop \
  nano \
  nginx \
  supervisor \
  unzip \
  zsh


# Composer
RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/bin --filename=composer  

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm


# Config files
COPY start.sh /usr/local/bin/start
COPY config/etc /etc
COPY config/etc/php/8.3/cli/conf.d/y-php.ini /etc/php/8.3/fpm/conf.d/y-php.ini

# Permissions for start script
RUN chmod a+x /usr/local/bin/start 

RUN mkdir -p /run/php

# Laravel Installer 
RUN composer global require laravel/installer && composer clear-cache    

# OhMyZsh (better than "bash")
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 

# Add composer to PATH
RUN echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.zshrc 

# Nginx (8080), Node (3000/3001), Laravel Dusk (9515/9773)
EXPOSE 8080 8000 3000 3001 9515 9773

# Start services through "supervisor" based on "CONTAINER_ROLE". See "start.sh".
CMD /usr/local/bin/start

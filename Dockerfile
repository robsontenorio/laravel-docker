FROM ubuntu:20.04

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

ENV TZ=UTC 
ENV DEBIAN_FRONTEND=noninteractive 
ENV CONTAINER_ROLE=${CONTAINER_ROLE:-APP} 
ENV GITHUB_OAUTH_KEY=${GITHUB_OAUTH_KEY:-} 

WORKDIR /var/www/html

RUN apt update \
  # PHP 8.0 repository 
  && apt install -y software-properties-common && add-apt-repository ppa:ondrej/php \
  && apt update \
  # PHP extensions
  && apt install -y \  
  php8.0-bcmath \
  php8.0-cli \
  php8.0-curl \
  php8.0-fpm \
  php8.0-gd \
  php8.0-mbstring  \ 
  php8.0-mysql \  
  php8.0-redis \  
  php8.0-sockets \  
  php8.0-sqlite3 \  
  php8.0-pcov \
  php8.0-pgsql \
  php8.0-opcache \
  php8.0-xml \ 
  # Extra
  curl \
  git \
  nano \
  nginx \
  supervisor \
  unzip \
  zsh \  
  # Clean up
  && apt-get autoremove -y 

# OhMyZsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 

# Composer
RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/bin --filename=composer  \
  && echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.zshrc \
  && if [ ${GITHUB_OAUTH_KEY} ]; then composer config --global github-oauth.github.com $GITHUB_OAUTH_KEY ;fi

# Laravel Installer 
RUN composer global require laravel/installer && composer clear-cache    

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm

# Config files
COPY start.sh /usr/local/bin/start
COPY config/etc /etc
COPY config/etc/php/8.0/cli/conf.d/y-php.ini /etc/php/8.0/fpm/conf.d/y-php.ini

# Required folder for php-fpm
RUN mkdir -p /run/php 

# Permissions
RUN chmod a+x /usr/local/bin/start 

# Nginx (8080), Node (3000/3001), Laravel Dusk (9515/9773)
EXPOSE 8080 8000 3000 3001 9515 9773

# Start services through "supervisor" based on "CONTAINER_ROLE". See "start.sh".
CMD /usr/local/bin/start

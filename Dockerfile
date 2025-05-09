FROM ubuntu:24.04

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

ENV TZ=UTC
ENV LANG="C.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive
ARG CONTAINER_ROLE=APP
ENV CONTAINER_ROLE=${CONTAINER_ROLE}

WORKDIR /var/www/app

RUN apt update \
  # Add PHP 8.4 repository
  && apt install -y software-properties-common && add-apt-repository ppa:ondrej/php \
  # PHP extensions
  && apt install -y \
  php8.4-bcmath \
  php8.4-cli \
  php8.4-curl \
  php8.4-fpm \
  php8.4-gd \
  php8.4-intl \
  php8.4-mbstring  \
  php8.4-mysql \
  php8.4-redis \
  php8.4-sockets \
  php8.4-sqlite3 \
  php8.4-pcov \
  php8.4-pgsql \
  php8.4-opcache \
  php8.4-xml \
  php8.4-zip \
  # Extra
  curl \
  git \
  gnupg \
  htop \
  nano \
  nginx \
  supervisor \
  unzip \
  zsh

# Other database drivers
COPY databases /tmp/databases
RUN chmod a+x -R /tmp/databases
RUN /tmp/databases/sqlserver.sh

# Composer
RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/bin --filename=composer

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm

# Create user/group with id/uid (1000/1000)
RUN userdel ubuntu
RUN groupadd -f -g 1000 appuser
RUN useradd -u 1000 -m -d /home/appuser -g appuser appuser

# Config files
COPY --chown=appuser:appuser start.sh /usr/local/bin/start
COPY --chown=appuser:appuser config/etc /etc
COPY --chown=appuser:appuser config/etc/php/8.4/cli/conf.d/y-php.ini /etc/php/8.4/fpm/conf.d/y-php.ini

# Permissions for start script
RUN chmod a+x /usr/local/bin/start

# Required for php-fpm and nginx as non-root user
RUN mkdir -p /run/php
RUN chown -R appuser:appuser /var/www/app /var/log /var/lib /run
RUN chmod -R 777 /var/log /var/lib /run

# Switch to non-root user
USER appuser

# Laravel Installer
RUN composer global require laravel/installer && composer clear-cache

# OhMyZsh (better than "bash")
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Add composer to PATH
RUN echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.zshrc

# Add SQL Tools to PATH
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.zshrc

# Nginx (8080), Node (3000/3001), Laravel Dusk (9515/9773)
EXPOSE 8080 8000 3000 3001 9515 9773

# Start services through "supervisor" based on "CONTAINER_ROLE". See "start.sh".
CMD ["/usr/local/bin/start"]

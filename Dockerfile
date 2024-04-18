FROM ubuntu:22.04

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

ENV TZ=UTC 
ENV LANG="C.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive 
ENV CONTAINER_ROLE=${CONTAINER_ROLE:-APP} 

WORKDIR /var/www/app

RUN apt update \
      # Add PHP 8.3 repository \
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
      sudo  \
      supervisor \
      unzip \
      zsh


# Create `appuser` (1000/1000)
RUN groupadd -g 1000 appuser
RUN useradd -p '' -u 1000 -m -d /home/appuser -g appuser appuser

# Config files
COPY --chown=appuser:appuser start.sh /usr/local/bin/start
COPY --chown=appuser:appuser config/etc /etc
COPY --chown=appuser:appuser config/etc/php/8.3/cli/conf.d/y-php.ini /etc/php/8.3/fpm/conf.d/y-php.ini

# Permissions
RUN chmod a+x /usr/local/bin/start
RUN mkdir -p /run/php
RUN chown -R appuser:appuser /var/www/app  /var/log /var/lib /run

# Composer
RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/local/bin --filename=composer

# Switch to non-root user
USER appuser

# Laravel Installer
RUN composer global require laravel/installer && composer clear-cache

# OhMyZsh (better than "bash")
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Node, NPM, Yarn
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ]  && . ${HOME}/.nvm/nvm.sh && nvm install --lts \
    && echo 'export PATH="$PATH:$HOME/.nvm/versions/node/'$(node -v)'/bin"' >> ~/.zshrc \
    && corepack enable && corepack prepare yarn@stable --activate

# Nginx (8080)
EXPOSE 8080

# Start services through "supervisor" based on "CONTAINER_ROLE". See "start.sh".
CMD /usr/local/bin/start

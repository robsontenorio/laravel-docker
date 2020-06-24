FROM php:7.4.6-fpm-alpine3.11

LABEL maintainer="Robson Tenório"
LABEL site="http://github.com/robsontenorio/laravel-docker"

# ENV
ARG GITHUB_OAUTH_KEY
ENV GITHUB_OAUTH_KEY=${GITHUB_OAUTH_KEY}
ENV CONTAINER_ROLE=${CONTAINER_ROLE:-APP}

# Set workdir
WORKDIR /var/www/app

# Create the "appuser" , but don't switch yet
RUN adduser -D appuser

# Copy files with owner
COPY --chown=appuser:appuser config /
COPY --chown=appuser:appuser start.sh /usr/local/bin/start

RUN chmod a+x -R /tmp /usr/local/bin/start

# Install temporary build dependencies
RUN apk add --update --no-cache --virtual .build-deps $PHPIZE_DEPS 

# Install required utilities
RUN apk add --update --no-cache \        
  bash \  
  chromium-chromedriver \
  git \      
  htop \
  libpng-dev \
  libzip-dev \   
  nano \        
  nginx \
  npm \
  openssh-client \
  postgresql-dev \
  poppler-utils \    
  rsync \
  supervisor \ 
  yarn 

# Install extra php extensions
RUN docker-php-ext-install \
  gd \  
  pdo_mysql \
  pdo_pgsql \
  opcache \
  zip

# Complementar pecl/pear extensions
# Note
# - xdebug: will not be enabled by default
# - pcov: although enabled here, will be disabled by php.ini
RUN pecl install redis xdebug pcov
RUN docker-php-ext-enable redis pcov

# Cleanup temporary dev dependencies and clean cache
RUN apk del -f .build-deps

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer 

# Set permissions
RUN chmod -R 777 \    
  /var/run \
  /var/log \
  /var/tmp \
  /var/lib \
  /var/www/app \
  /usr/local/etc/php/conf.d/xdebug.disabled

RUN chown -R appuser:appuser \
  /var/www/app/  \
  /usr/local/etc/php/conf.d/xdebug.disabled


# Run container as non root user
USER appuser

# Github oauth key, recommended by Prestissimo
RUN if [ ${GITHUB_OAUTH_KEY} ]; then \
  composer config -g github-oauth.github.com $GITHUB_OAUTH_KEY \
  ;fi

# Laravel Installer and Prestissimo
RUN composer global require laravel/installer \
  && composer global require hirak/prestissimo \
  && composer clear-cache

# Path and handy aliases
RUN echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc  \
  && echo 'alias t="./vendor/bin/phpunit-watcher watch"' >> ~/.bashrc \ 
  && source ~/.bashrc

# Expose needed ports for nginx/node/dusk
EXPOSE 8080 8000 3000 3001 9515 9773

CMD /usr/local/bin/start
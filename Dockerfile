FROM dunglas/frankenphp

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

# Linux packages
RUN apt update && \
    apt install -y \
        git \
        zsh \
        unzip \
        nano \
        htop \
        supervisor \
        pass \
        default-mysql-client

# PHP extensions
RUN install-php-extensions \
    gd \
    intl \
    opcache \
    pcntl \
    pcov \
    pdo_pgsql \
    pdo_mysql \
    redis \
    sockets \
    zip

# Database extras
COPY config/database.sh /tmp/database.sh
RUN chmod +x /tmp/database.sh && /tmp/database.sh

# PHP setting
COPY config/php.ini "$PHP_INI_DIR/php.ini"

# Composer
RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/bin --filename=composer    

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm

# Start script
COPY start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start

# Create non-root user
RUN useradd -m -s /bin/zsh appuser && \
    setcap -r /usr/local/bin/frankenphp && \
	chown -R appuser:appuser /data/caddy && \
    chown -R appuser:appuser /config/caddy && \
    chown -R appuser:appuser /app

# Switch user
USER appuser

# OhMyZSH
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Laravel installer
RUN COMPOSER_HOME=/home/appuser/.composer composer global require laravel/installer && \ 
    composer clear-cache && \
    echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.zshrc

ENV SERVER_NAME=:8000

EXPOSE 8000

CMD ["start"]
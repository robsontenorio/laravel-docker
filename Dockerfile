FROM dunglas/frankenphp

LABEL maintainer="Robson Tenório"
LABEL site="https://github.com/robsontenorio/laravel-docker"

# Linux packages
RUN apt update && \
    apt install -y git zsh unzip nano htop supervisor pass && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN install-php-extensions gd intl opcache pcntl pcov pgsql redis sockets zip

# Composer / Laravel Installer
RUN curl -sS https://getcomposer.org/installer  | php -- --install-dir=/usr/bin --filename=composer && \
    composer global require laravel/installer && composer clear-cache

# Node, NPM, Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && npm -g install yarn --unsafe-perm

# Start script
COPY start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start

# Create non-root user
RUN useradd -m -s /bin/zsh appuser && \
	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp && \
	chown -R appuser:appuser /data/caddy && chown -R appuser:appuser /config/caddy

# Switch user
USER appuser

# OhMyZSH
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

CMD ["start"]
FROM php:8.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git zip unzip imagemagick webp poppler-utils  \
    libwebp-dev libavif-dev libicu-dev libpq-dev libzip-dev libpng-dev \
    libfreetype6-dev libjpeg62-turbo-dev librabbitmq-dev libssh-dev libmagickwand-dev && \
    apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

RUN pecl install amqp && \
    pecl install imagick && \
    docker-php-ext-enable amqp imagick && \
    docker-php-ext-install -j$(nproc) bcmath pdo_mysql gd zip exif intl

COPY policy.xml /etc/ImageMagick-6/policy.xml

# Install composer with hirak/prestissimo
RUN curl -sS https://getcomposer.org/composer-stable.phar -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

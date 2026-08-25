FROM composer:2.10.2@sha256:4d71c3c2109c61d5415544264b59ad4087e4c5b7244481723664138fd36d5040 AS composer
FROM php:8.3-fpm@sha256:df9666c3ff99b15b8ac54b0d69d912a44c351d8f39b8b0c8b9301241f5a5d4f8

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl git zip unzip imagemagick webp poppler-utils \
        libwebp-dev libavif-dev libicu-dev libpq-dev libzip-dev libpng-dev \
        libfreetype6-dev libjpeg62-turbo-dev librabbitmq-dev libssh-dev libmagickwand-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-avif; \
    pecl install amqp imagick; \
    docker-php-ext-enable amqp imagick; \
    docker-php-ext-install -j"$(nproc)" bcmath pdo_mysql gd zip exif intl; \
    apt-get clean; \
    rm -rf /tmp/pear /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY policy.xml /tmp/policy.xml
RUN set -eux; \
    imageMagickConfigDir="$(convert -list configure | awk '$1 == "CONFIGURE_PATH" { print $2; exit }' | cut -d: -f1)"; \
    cp /tmp/policy.xml "$imageMagickConfigDir/policy.xml"; \
    rm /tmp/policy.xml

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

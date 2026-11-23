FROM composer:2.11.1@sha256:8de2184c6de224f4689e8f80ed5f5edaf0030b6b8b7839a22a2bcb6722ac87d0 AS composer
# PHP 8.4.27
FROM php:8.4-fpm@sha256:89aa7c69dedff16e4076f955578547b62566b7f9aa6a0caa6b34b554490be4f0

ARG AMQP_VERSION=2.2.0
ARG IMAGICK_VERSION=3.8.1

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl git zip unzip imagemagick webp poppler-utils \
        libwebp-dev libavif-dev libicu-dev libpq-dev libzip-dev libpng-dev \
        libfreetype6-dev libjpeg62-turbo-dev librabbitmq-dev libssh-dev libmagickwand-dev; \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp --with-avif; \
    docker-php-source extract; \
    mkdir -p /usr/src/php/ext/amqp /usr/src/php/ext/imagick; \
    curl -fsSL --retry 3 "https://github.com/php-amqp/php-amqp/archive/refs/tags/v${AMQP_VERSION}.tar.gz" -o /tmp/amqp.tar.gz; \
    tar xzf /tmp/amqp.tar.gz -C /usr/src/php/ext/amqp --strip-components=1; \
    curl -fsSL --retry 3 "https://github.com/Imagick/imagick/archive/refs/tags/${IMAGICK_VERSION}.tar.gz" -o /tmp/imagick.tar.gz; \
    tar xzf /tmp/imagick.tar.gz -C /usr/src/php/ext/imagick --strip-components=1; \
    sed -i "s/@PACKAGE_VERSION@/${IMAGICK_VERSION}/g" /usr/src/php/ext/imagick/php_imagick.h; \
    docker-php-ext-install -j"$(nproc)" amqp imagick bcmath pdo_mysql gd zip exif intl; \
    docker-php-source delete; \
    rm -f /tmp/amqp.tar.gz /tmp/imagick.tar.gz; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY policy.xml /tmp/policy.xml
RUN set -eux; \
    imageMagickConfigDir="$(convert -list configure | awk '$1 == "CONFIGURE_PATH" { print $2; exit }' | cut -d: -f1)"; \
    cp /tmp/policy.xml "$imageMagickConfigDir/policy.xml"; \
    rm /tmp/policy.xml

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

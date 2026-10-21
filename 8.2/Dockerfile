FROM composer:2.10.3@sha256:af98f42dfff7c68ba8d53c2164fd9fde1087b7d449514baa38c418b1f6bc4bac AS composer
# PHP 8.2.35 (linux/amd64), 8.2.34 (linux/arm64)
FROM php:8.2-fpm@sha256:b72a79e3d39b0977c44723eed5c06b4c4eea5db1b2d98dfd24fdda9cb21d0ef1

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

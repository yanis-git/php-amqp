FROM composer:2.10.3@sha256:b6dcd72ca98fa19d0e5b8476de179859704891fad06dd9e0b96833d4c430a5fc AS composer
# PHP 8.3.36
FROM php:8.3-fpm@sha256:401353d70d4376b746ab505a789379a97c8afdff3a147de81ea1e8ca035a5fe3

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

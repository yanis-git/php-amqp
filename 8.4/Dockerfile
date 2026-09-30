FROM composer:2.10.3@sha256:9715c7f69044da2a212a5fbde29ee7da24e364d426560ae6367b060236f847d7 AS composer
FROM php:8.4-fpm@sha256:59fa733c9af643a122f8a9976119460e35ce76dd0a3f2b9c8f75af8e361a54e2

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

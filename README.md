# PHP AMQP Docker images

`yanisdocaxess/php-amqp` provides PHP-FPM images with the `amqp` and `imagick`
extensions preinstalled, plus commonly used PHP extensions and command-line tools.
It is intended as a small base image for applications that need RabbitMQ/AMQP
support and ImageMagick processing.

## Tags and platforms

The published PHP tags are `8.2`, `8.3`, `8.4`, and `8.5`. Each tag is built
for `linux/amd64` and `linux/arm64`.

```sh
docker pull yanisdocaxess/php-amqp:8.4
docker run --rm yanisdocaxess/php-amqp:8.4 php -v
```

## Included software

PHP extensions: `amqp`, `imagick`, `bcmath`, `exif`, `gd`, `intl`, `pdo_mysql`,
and `zip`.

The images also include Composer and the following OS tools: `curl`, `git`,
`zip`, `unzip`, ImageMagick, `webp`, and Poppler utilities.

GD is configured with FreeType, JPEG, WebP, and AVIF support using the
libraries available in the underlying official PHP image.

## AMQP verification

This confirms that the PHP AMQP extension is loaded; it does not connect to a
broker:

```sh
docker run --rm yanisdocaxess/php-amqp:8.4 \
  php -r 'echo extension_loaded("amqp") ? "amqp loaded\n" : "amqp missing\n";'
```

To use an AMQP broker from an application, configure the connection settings
for the broker reachable from the container; no broker is bundled in this
image.

## Building locally

Build a particular PHP variant from the repository root:

```sh
docker build -t php-amqp:8.4 ./8.4
docker run --rm php-amqp:8.4 php -m
```

For a multi-platform build without publishing, use Buildx with an OCI archive
output:

```sh
docker buildx build --platform linux/amd64,linux/arm64 \
  --output type=oci,dest=php-amqp-8.4.oci ./8.4
```

## Releases and maintenance

Pushing to the repository's `main` branch triggers one multi-platform Docker
Hub publication per supported PHP tag. Pull requests only build and smoke-test
the images; they do not authenticate to Docker Hub or push images.

The official PHP base images, Composer, and GitHub Actions are pinned to immutable
references. Dependabot is configured to propose updates for those references;
base-image fixes therefore arrive through reviewed dependency updates rather than
silently changing a rebuild. Review and publish updates promptly when security
fixes are needed—these images do not by themselves guarantee that all downstream
dependencies or deployed containers are current or vulnerability-free.

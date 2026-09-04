# syntax=docker/dockerfile:1
# Updated by scripts/update_agendav.py from official signed release metadata.
ARG AGENDAV_VERSION=3.3.1
ARG AGENDAV_SHA256=aec1038845ea9b489f575028d092fb7ef3dbee7dcf302783a3f6d383e7473030

FROM php:8.5-apache@sha256:609de4eac65a03f20975441c9c3f313811d785575f0d02413c630753ab5c5532
ARG AGENDAV_VERSION
ARG AGENDAV_SHA256

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl libicu-dev libzip-dev \
 && docker-php-ext-install -j"$(nproc)" intl pdo_mysql zip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN curl --fail --location --show-error --output agendav.tar.gz \
      "https://github.com/agendav/agendav/releases/download/${AGENDAV_VERSION}/agendav-${AGENDAV_VERSION}.tar.gz" \
 && echo "${AGENDAV_SHA256}  agendav.tar.gz" | sha256sum --check \
 && tar --extract --gzip --file agendav.tar.gz --strip-components=1 \
 && rm agendav.tar.gz \
 && a2enmod rewrite \
 && sed -ri 's!/var/www/html!/app/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY docker/agendav.conf /etc/apache2/conf-available/agendav.conf
RUN a2enconf agendav

COPY docker-entrypoint.sh /usr/local/bin/agendav-entrypoint
RUN chmod 755 /usr/local/bin/agendav-entrypoint

ENV AGENDAV_ENVIRONMENT=prod \
    AGENDAV_DATA_DIR=/data \
    AGENDAV_TIMEZONE=Europe/Vienna \
    AGENDAV_LANGUAGE=de_DE

VOLUME ["/data"]
EXPOSE 80
ENTRYPOINT ["agendav-entrypoint"]
CMD ["apache2-foreground"]

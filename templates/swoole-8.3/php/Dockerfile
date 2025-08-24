ARG BASE_IMAGE

FROM $BASE_IMAGE

RUN apk add --virtual .build-deps --no-cache --update autoconf file g++ gcc libc-dev make pkgconf re2c zlib-dev linux-headers && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    apk del .build-deps

COPY --from=composer:2.5 /usr/bin/composer /usr/bin/composer

RUN apk add npm git openjdk8-jre-base bash htop vim mc less

ARG USER_ID
ARG GROUP_ID

RUN addgroup -g $GROUP_ID developer
RUN adduser -u $USER_ID -S -D -H -G developer developer
RUN addgroup www-data developer
RUN addgroup developer www-data

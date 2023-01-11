ARG BASE_IMAGE

FROM $BASE_IMAGE

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID user
RUN adduser -u $GROUP_ID -S -D -H -G user user
RUN addgroup www-data user
RUN addgroup user www-data

RUN apk add npm git openjdk8-jre-base bash htop vim mc

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apk add --virtual .build-deps --no-cache --update autoconf file g++ gcc libc-dev make pkgconf re2c zlib-dev linux-headers && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    apk del .build-deps
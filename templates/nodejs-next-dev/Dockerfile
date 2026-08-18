FROM node:22.18.0-alpine3.22

RUN apk add --no-cache libc6-compat

ARG USER_ID
ARG GROUP_ID

RUN if ! getent group "$GROUP_ID" >/dev/null 2>&1; then addgroup -g "$GROUP_ID" developer; fi
RUN if ! getent passwd "$USER_ID" >/dev/null 2>&1; then adduser -u "$USER_ID" -S -D -h /tmp/home -G "$(getent group "$GROUP_ID" | cut -d: -f1)" developer; fi

WORKDIR /var/www

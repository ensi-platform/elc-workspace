ARG BASE_IMAGE

FROM $BASE_IMAGE

RUN apk add npm git bash htop vim mc less

ARG USER_ID
ARG GROUP_ID

RUN if ! getent group "$GROUP_ID" >/dev/null 2>&1; then addgroup -g "$GROUP_ID" developer; fi
RUN if ! getent passwd "$USER_ID" >/dev/null 2>&1; then adduser -u "$USER_ID" -S -D -h /tmp/home -G "$(getent group "$GROUP_ID" | cut -d: -f1)" developer; fi

WORKDIR /var/www
USER $USER_ID

ENTRYPOINT ["/tmp/home/go/bin/air"]
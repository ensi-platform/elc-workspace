ARG BASE_IMAGE
ARG MISE_VERSION=2026.9.12

FROM ghcr.io/jdx/mise:${MISE_VERSION} AS mise

FROM $BASE_IMAGE

COPY --from=mise /usr/local/bin/mise /usr/local/bin/mise

RUN apk add --no-cache npm git bash ca-certificates gcc musl-dev htop vim mc less

ENV MISE_DATA_DIR=/tmp/home/.mise \
    MISE_CACHE_DIR=/tmp/home/.cache/mise \
    PATH="/tmp/home/go/bin:/tmp/home/.mise/shims:${PATH}"

ARG USER_ID
ARG GROUP_ID

RUN if ! getent group "$GROUP_ID" >/dev/null 2>&1; then addgroup -g "$GROUP_ID" developer; fi
RUN if ! getent passwd "$USER_ID" >/dev/null 2>&1; then adduser -u "$USER_ID" -S -D -h /tmp/home -G "$(getent group "$GROUP_ID" | cut -d: -f1)" developer; fi

WORKDIR /var/www
USER $USER_ID

ENTRYPOINT ["/usr/local/bin/mise", "exec", "--", "air"]

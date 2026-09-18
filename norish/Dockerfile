# syntax=docker/dockerfile:1
#
# Home Assistant add-on image for Norish.
#
# Built on top of the official norishapp/norish image (Alpine based) and adds:
#   * PostgreSQL 17 and Redis (both run inside the add-on, data in /data)
#   * s6-overlay v3 + bashio, the process supervisor / helper library that
#     Home Assistant add-ons use
#
# Obscura (the headless browser used for URL imports) is a glibc binary and
# therefore ships as a separate add-on (../norish_obscura) using the upstream
# image unchanged.
#
# NORISH_VERSION is the upstream Docker tag / GitHub release tag. It is kept in
# sync automatically by .github/workflows/update-upstream.yml.
ARG NORISH_VERSION=v0.23.1-beta
FROM norishapp/norish:${NORISH_VERSION}

ARG NORISH_VERSION
ARG S6_OVERLAY_VERSION=3.2.3.2
ARG BASHIO_VERSION=0.19.0
ARG BUILD_VERSION
ARG BUILD_ARCH

USER root
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

# Runtime tooling + the two bundled services.
RUN apk add --no-cache \
        bash \
        curl \
        jq \
        tzdata \
        xz \
        su-exec \
        postgresql17 \
        postgresql17-client \
        redis \
    && mkdir -p /run/postgresql \
    && chown postgres:postgres /run/postgresql

# s6-overlay v3 (arch detected inside the build so it works for native,
# emulated and Supervisor-local builds alike).
RUN set -eu; \
    arch="$(uname -m)"; \
    case "$arch" in \
        x86_64|aarch64) ;; \
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}"; \
    curl -fsSL "${base}/s6-overlay-noarch.tar.xz" | tar -C / -Jxpf -; \
    curl -fsSL "${base}/s6-overlay-${arch}.tar.xz" | tar -C / -Jxpf -

# bashio (Home Assistant add-on helper library)
RUN set -eu; \
    mkdir -p /tmp/bashio; \
    curl -fsSL "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
        | tar -xzf - --strip-components=1 -C /tmp/bashio; \
    mv /tmp/bashio/lib /usr/lib/bashio; \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio; \
    rm -rf /tmp/bashio

COPY rootfs /

RUN chmod +x /etc/s6-overlay/scripts/* \
    && find /etc/s6-overlay/s6-rc.d -type f \( -name run -o -name finish -o -name up \) -exec chmod +x {} +

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SERVICES_GRACETIME=15000 \
    S6_KEEP_ENV=1 \
    NORISH_UPSTREAM_VERSION=${NORISH_VERSION}

LABEL \
    io.hass.name="Norish" \
    io.hass.description="Realtime, self-hosted recipe app for families & friends" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.arch="${BUILD_ARCH}" \
    org.opencontainers.image.title="Norish Home Assistant add-on" \
    org.opencontainers.image.source="https://github.com/jonbuhl/ha-norish-addons" \
    org.opencontainers.image.version="${BUILD_VERSION}"

WORKDIR /app
EXPOSE 3000
ENTRYPOINT ["/init"]
CMD []

# syntax=docker/dockerfile:1
#
# Home Assistant add-on image for Obscura, the headless browser Norish uses to
# render recipe pages for URL imports.
#
# The browser binaries come unchanged from Norish's own image
# (norishapp/obscura, the render+stealth build). That image is distroless and
# has no shell, so it cannot read Home Assistant options or the shared CDP
# token. This image copies the two binaries onto a slim Debian (glibc, same
# major as distroless/cc-debian12) and starts them through run.sh.
#
# OBSCURA_TAG is the upstream image tag pinned by the current Norish release.
# It is kept in sync automatically by .github/workflows/update-upstream.yml.
ARG OBSCURA_TAG=0.2.4-norish.1
FROM norishapp/obscura:${OBSCURA_TAG} AS obscura

FROM debian:12-slim

ARG OBSCURA_TAG
ARG BUILD_VERSION
ARG BUILD_ARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=obscura /obscura /obscura
COPY --from=obscura /obscura-worker /obscura-worker
COPY --from=obscura /licenses /licenses
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENV OBSCURA_UPSTREAM_TAG=${OBSCURA_TAG}

LABEL \
    io.hass.name="Norish Obscura" \
    io.hass.description="Headless browser used by Norish for URL imports" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    io.hass.arch="${BUILD_ARCH}" \
    org.opencontainers.image.title="Norish Obscura Home Assistant add-on" \
    org.opencontainers.image.source="https://github.com/jonbuhl/ha-norish-addons" \
    org.opencontainers.image.version="${BUILD_VERSION}" \
    org.opencontainers.image.licenses="Apache-2.0"

EXPOSE 9222
ENTRYPOINT ["/run.sh"]

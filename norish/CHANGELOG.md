# Changelog

## 0.25.1-beta-ha1

- Pass `OBSCURA_CDP_TOKEN` to Norish. The token is shared with the Norish
  Obscura add-on via `/share/norish/obscura_cdp_token` and generated
  automatically. Fixes URL imports with Obscura 0.2.4.


## 0.25.1-beta

- Update Norish to [v0.25.1-beta](https://github.com/norish-recipes/norish/releases/tag/v0.25.1-beta).


## 0.25.0-beta

- Update Norish to [v0.25.0-beta](https://github.com/norish-recipes/norish/releases/tag/v0.25.0-beta).


## 0.24.0-beta

- Update Norish to [v0.24.0-beta](https://github.com/norish-recipes/norish/releases/tag/v0.24.0-beta).


## 0.23.1-beta-ha2

- Ship `icon.png` (128x128) and `logo.png` (250x100) so the add-on shows the
  Norish mark in the Home Assistant app store instead of the generic
  placeholder. Both are derived from the official Norish assets
  (`apps/web/public/android-chrome-512x512.png` and `apps/web/public/logo.svg`).

## 0.23.1-beta-ha1

- Bind Norish dual-stack (`HOST=::`). The add-on port is published on IPv4 and
  IPv6, but the app only listened on IPv4. Clients that resolve
  `homeassistant.local` via mDNS receive an IPv6 link-local address and connect
  over IPv6 first, which ended in a connection reset without any data
  (`NS_ERROR_NET_EMPTY_RESPONSE` in the browser) — while IPv4 clients and
  other add-ons worked fine.

## 0.23.1-beta

- Initial add-on release, tracks Norish `v0.23.1-beta`.
- Bundles PostgreSQL 17 and Redis; all data in `/data`.

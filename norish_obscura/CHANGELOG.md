# Changelog

## 0.2.4-norish.1-ha1

- Build an own image from the `norishapp/obscura:0.2.4-norish.1` binaries so
  the add-on can pass `OBSCURA_CDP_TOKEN`. Obscura 0.2.4 refuses to start
  without it, which broke URL imports after the previous update.
- The token is generated automatically and shared with the Norish add-on via
  `/share/norish/obscura_cdp_token`.


## 0.2.4-norish.1

- Track `norishapp/obscura:0.2.4-norish.1` as pinned by Norish v0.25.1-beta.


## 0.2.2-norish.1

- Track `norishapp/obscura:0.2.2-norish.1` as pinned by Norish v0.24.0-beta.


## 0.2.0-norish.1

- Initial version, tracks `norishapp/obscura:0.2.0-norish.1`.

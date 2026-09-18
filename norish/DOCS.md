# Norish

[Norish](https://github.com/norish-recipes/norish) is a realtime, self-hosted
recipe app for families and friends: recipes, meal planning, shared grocery
lists. This add-on bundles Norish, PostgreSQL 17 and Redis in one container.
All data lives in `/data` and is included in Home Assistant backups.

## Installation

1. Add this repository to Home Assistant: **Settings → Add-ons → Add-on Store →
   ⋮ → Repositories** and paste the repository URL.
2. Install **Norish** and (recommended) **Norish Obscura**. Obscura is only
   needed for importing recipes from URLs.
3. Open the Norish configuration tab and set `auth_url` to the address you
   will use in the browser, e.g. `http://192.168.1.50:3000`. If you leave it
   empty the add-on guesses the host IP.
4. Start the add-on and open the web UI on port 3000. The first user to sign
   up becomes the admin; registration closes afterwards.

To receive new Norish versions automatically, enable **Auto update** on the
info page of the add-on. New versions show up here once the GitHub Actions
workflow of this repository has built the image, usually within a day of the
upstream release.

## Options

| Option | Description |
| --- | --- |
| `auth_url` | Public URL of Norish, used for auth callbacks and cookies. Must match what you type in the browser (IP or hostname, with port). |
| `trusted_origins` | Additional origins you access Norish from, e.g. `https://norish.example.com` behind a reverse proxy. |
| `master_key` | Encryption master key. Leave empty to have one generated and stored in `/data/master_key`. Set it only when migrating an existing installation. Never change it afterwards. |
| `obscura_endpoint` | Override the Obscura websocket endpoint. Empty means the companion add-on. |
| `password_auth_enabled` | Allow e-mail + password login. |
| `default_locale` | Default UI language, e.g. `de`, `en`, `nl`. |
| `enabled_locales` | Comma-separated list of allowed languages; empty means all. |
| `log_level` | `trace`, `debug`, `info`, `warn`, `error`, `fatal`. |
| `env_vars` | Any additional Norish environment variable, e.g. OIDC settings. |

Example for OIDC:

```yaml
env_vars:
  - name: OIDC_NAME
    value: Authentik
  - name: OIDC_ISSUER
    value: https://auth.example.com/application/o/norish/
  - name: OIDC_CLIENT_ID
    value: xxxxxxxx
  - name: OIDC_CLIENT_SECRET
    value: yyyyyyyy
```

See the upstream
[server & runtime reference](https://docs.norish.dev/configuration/server-runtime)
for every supported variable.

## Reverse proxy / HTTPS

Point your proxy (Nginx Proxy Manager add-on, Caddy, Traefik, ...) at
`http://<ha-ip>:3000`, set `auth_url` to the public HTTPS URL and add the
local URL to `trusted_origins` if you also open it directly.

## Backups

The add-on is stopped while a Home Assistant backup runs (`backup: cold`) so
the PostgreSQL data files are consistent. Backups contain the database, the
uploads and the master key.

## Migrating from a Docker Compose installation

1. Put your existing `MASTER_KEY` into the `master_key` option.
2. Start the add-on once so the PostgreSQL cluster is created.
3. Restore your dump, e.g. from the SSH add-on with Docker access:

   ```bash
   docker exec -i addon_<repo>_norish su-exec postgres psql -U postgres norish < dump.sql
   docker cp ./uploads/. addon_<repo>_norish:/data/uploads/
   ```

4. Restart the add-on.

## Troubleshooting

- **Login loops or "invalid origin"**: `auth_url` does not match the URL in
  the browser. Fix it and restart.
- **URL import fails**: the Norish Obscura add-on is not installed or not
  running.
- **Update fails to pull the image**: the GitHub Actions build for that
  version may still be running, or the GHCR package is private. Check the
  Actions tab and the package visibility.

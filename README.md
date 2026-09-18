# Norish Home Assistant Add-ons

Home Assistant add-on repository for [Norish](https://github.com/norish-recipes/norish),
the realtime self-hosted recipe app.

[![Add repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fjonbuhl%2Fha-norish-addons)

| Add-on | What it is |
| --- | --- |
| **Norish** | Norish + PostgreSQL 17 + Redis in one container. |
| **Norish Obscura** | Headless browser for URL imports (upstream image, unchanged). |

Supported architectures: `aarch64` (Raspberry Pi 4/5, ODROID, ...) and `amd64`.

## How updates work

The scheduled GitHub Actions workflow `update-upstream.yml` runs daily:

1. Looks up the highest `vX.Y.Z*` tag of `norishapp/norish` on Docker Hub that
   exists for arm64 and amd64, plus the Obscura tag that release pins. It never
   moves to a lower version than the one currently shipped.
2. Builds `ghcr.io/<you>/norish-addon:<version>` for arm64 and amd64.
3. Only after the image is pushed, bumps `version` in both `config.yaml`
   files and commits to `main`.

Home Assistant then shows the update. With **Auto update** enabled on the
add-on it installs itself.

## One-time setup after cloning

1. Create a **public** GitHub repository, e.g. `ha-norish-addons`, and push
   this content to its `main` branch.
2. Replace the placeholder with your GitHub user name (lower-case):

   ```bash
   ./scripts/set-owner.sh your-github-user
   ```

3. Push to `main`. The **Build Norish add-on image** workflow runs
   automatically (it can also be started from the Actions tab). The workflows
   request their own token permissions, so the default read-only workflow
   permissions of a new repository are sufficient.
4. After the first build, check that the package `norish-addon` on your
   GitHub profile is **Public**. Packages published from a public repository
   normally are; Home Assistant cannot pull private images.
5. Add the repository URL in Home Assistant and install the add-ons.

## Local build on the Home Assistant host

Copy the `norish` folder to `/addons/norish` (Samba or SSH add-on), comment
out the `image:` line in its `config.yaml` and install it as a local add-on.
Supervisor then builds the image on the device (a few minutes on a Pi 5).

## Versioning

The add-on version equals the upstream tag without the leading `v`
(`v0.23.1-beta` becomes `0.23.1-beta`). If the add-on itself needs a rebuild
without an upstream release, append `-ha1`, `-ha2`, ... by hand and run the
build workflow.

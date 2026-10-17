# Norish Obscura

Companion add-on for **Norish**. It runs [Obscura](https://github.com/h4ckf0r0day/obscura),
the headless browser Norish uses to render JavaScript-heavy recipe pages before
importing them from a URL.

There is nothing to configure. Install and start it; the Norish add-on finds it
automatically on the internal add-on network under
`ws://<repo>-norish-obscura:9222`.

If you never import recipes by URL you can leave this add-on uninstalled.
URL imports then fail with an "Obscura not reachable" error, everything else
works.

## CDP token

Since Obscura 0.2.4 the browser only accepts connections with a token of at
least 32 characters. The two add-ons share it automatically through
`/share/norish/obscura_cdp_token`: whichever add-on starts first generates
it, the other one reads it. The token is never written to the log and is not
part of this repository or the image.

The port is not published on the host, so only containers on the Home
Assistant add-on network can reach the browser at all. Keep in mind that
other add-ons with access to `/share` (Samba, SSH, File editor, ...) can read
the token file.

To rotate the token, delete the file and restart both add-ons.

## Image

The image is built by this repository. It contains the unchanged browser
binaries of `norishapp/obscura` (the render+stealth build published by the
Norish project) on a slim Debian base plus a small start script for the token.
The upstream tag is pinned to whatever the current Norish release expects and
is bumped automatically together with the Norish add-on.

## Troubleshooting

- **Add-on stops right after start with "No valid CDP token"**: `/share` is
  not writable. Check the log of the add-on.
- **URL import fails although both add-ons run**: restart Norish so it picks
  up the current token, e.g. after the token file was deleted.

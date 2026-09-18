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

The image is `norishapp/obscura`, published by the Norish project. Its tag is
pinned to whatever the current Norish release expects and is bumped
automatically together with the Norish add-on.

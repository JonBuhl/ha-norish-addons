#!/usr/bin/env bash
# Usage: scripts/bump.sh <norish-git-tag> [<obscura-image-tag>]
#
# Rewrites the versions in config.yaml / Dockerfile / CHANGELOG for a new
# upstream release. Deterministic on purpose: the build job and the commit job
# in CI both call it with the same arguments and end up with identical files.
#
# The upstream pins live in the Dockerfiles (ARG NORISH_VERSION, ARG
# OBSCURA_TAG). The add-on versions in config.yaml may carry a "-haN" suffix
# for repo-only rebuilds; a new upstream pin resets them to the plain tag.
set -euo pipefail
cd "$(dirname "$0")/.."

NORISH_TAG="${1:?norish tag required, e.g. v0.23.1-beta}"
OBSCURA_TAG="${2:-}"
NORISH_VERSION="${NORISH_TAG#v}"

pinned_norish="$(sed -n 's/^ARG NORISH_VERSION=//p' norish/Dockerfile | head -n1)"
if [[ "${pinned_norish}" != "${NORISH_TAG}" ]]; then
    yq -i ".version = \"${NORISH_VERSION}\" | .version style=\"double\"" norish/config.yaml
    sed -i "s|^ARG NORISH_VERSION=.*|ARG NORISH_VERSION=${NORISH_TAG}|" norish/Dockerfile
    {
        echo "# Changelog"
        echo
        echo "## ${NORISH_VERSION}"
        echo
        echo "- Update Norish to [${NORISH_TAG}](https://github.com/norish-recipes/norish/releases/tag/${NORISH_TAG})."
        echo
        tail -n +2 norish/CHANGELOG.md
    } > norish/CHANGELOG.md.new
    mv norish/CHANGELOG.md.new norish/CHANGELOG.md
    echo "norish: ${pinned_norish} -> ${NORISH_TAG}"
fi

if [[ -n "${OBSCURA_TAG}" ]]; then
    pinned_obscura="$(sed -n 's/^ARG OBSCURA_TAG=//p' norish_obscura/Dockerfile | head -n1)"
    if [[ "${pinned_obscura}" != "${OBSCURA_TAG}" ]]; then
        yq -i ".version = \"${OBSCURA_TAG}\" | .version style=\"double\"" norish_obscura/config.yaml
        sed -i "s|^ARG OBSCURA_TAG=.*|ARG OBSCURA_TAG=${OBSCURA_TAG}|" norish_obscura/Dockerfile
        {
            echo "# Changelog"
            echo
            echo "## ${OBSCURA_TAG}"
            echo
            echo "- Track \`norishapp/obscura:${OBSCURA_TAG}\` as pinned by Norish ${NORISH_TAG}."
            echo
            tail -n +2 norish_obscura/CHANGELOG.md
        } > norish_obscura/CHANGELOG.md.new
        mv norish_obscura/CHANGELOG.md.new norish_obscura/CHANGELOG.md
        echo "obscura: ${pinned_obscura} -> ${OBSCURA_TAG}"
    fi
fi

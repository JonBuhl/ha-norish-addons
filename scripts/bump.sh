#!/usr/bin/env bash
# Usage: scripts/bump.sh <norish-git-tag> [<obscura-image-tag>]
#
# Rewrites the versions in config.yaml / Dockerfile / CHANGELOG for a new
# upstream release. Deterministic on purpose: the build job and the commit job
# in CI both call it with the same arguments and end up with identical files.
set -euo pipefail
cd "$(dirname "$0")/.."

NORISH_TAG="${1:?norish tag required, e.g. v0.23.1-beta}"
OBSCURA_TAG="${2:-}"
NORISH_VERSION="${NORISH_TAG#v}"

current_norish="$(yq -r '.version' norish/config.yaml)"
if [[ "${current_norish}" != "${NORISH_VERSION}" ]]; then
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
    echo "norish: ${current_norish} -> ${NORISH_VERSION}"
fi

if [[ -n "${OBSCURA_TAG}" ]]; then
    current_obscura="$(yq -r '.version' norish_obscura/config.yaml)"
    if [[ "${current_obscura}" != "${OBSCURA_TAG}" ]]; then
        yq -i ".version = \"${OBSCURA_TAG}\" | .version style=\"double\"" norish_obscura/config.yaml
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
        echo "obscura: ${current_obscura} -> ${OBSCURA_TAG}"
    fi
fi

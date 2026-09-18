#!/usr/bin/env bash
# Usage: scripts/set-owner.sh <github-user-or-org>
# Replaces the YOUR_GITHUB_USER placeholder everywhere (image name, URLs).
set -euo pipefail
cd "$(dirname "$0")/.."
owner="$(echo "${1:?github user required}" | tr '[:upper:]' '[:lower:]')"
# The build action checks for the literal placeholder and this script contains
# it by definition, so both are excluded from the replacement.
grep -rl 'YOUR_GITHUB_USER' --exclude-dir=.git \
    --exclude=set-owner.sh --exclude=action.yml . | while read -r f; do
    sed -i "s/YOUR_GITHUB_USER/${owner}/g" "$f"
    echo "updated $f"
done

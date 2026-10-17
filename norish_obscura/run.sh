#!/bin/bash
# Entry point of the Norish Obscura add-on.
#
# Obscura only listens beyond loopback when OBSCURA_CDP_TOKEN holds at least
# 32 characters, and Norish must send the same value. Both add-ons share it
# through /share/norish/obscura_cdp_token: whichever add-on starts first
# creates it, the other one reads it. The token is never logged.
set -euo pipefail

TOKEN_DIR=/share/norish
TOKEN_FILE="${TOKEN_DIR}/obscura_cdp_token"

log() { printf '[%s] %s\n' "$1" "$2" >&2; }

new_token() {
    head -c 32 /dev/urandom | od -An -v -tx1 | tr -d ' \n'
}

read_token() {
    [[ -f "${TOKEN_FILE}" ]] || return 0
    tr -d '[:space:]' < "${TOKEN_FILE}"
}

# Creates the token file unless a valid one exists. The new file appears
# atomically (hard link), so two add-ons starting at the same moment end up
# with the same token: the second link fails and that add-on reads the first.
ensure_token() {
    mkdir -p "${TOKEN_DIR}"
    chmod 700 "${TOKEN_DIR}"
    local current
    current="$(read_token)"
    if (( ${#current} >= 32 )); then
        return 0
    fi
    local tmp
    tmp="$(mktemp "${TOKEN_DIR}/.obscura_cdp_token.XXXXXX")"
    new_token > "${tmp}"
    chmod 600 "${tmp}"
    if [[ -e "${TOKEN_FILE}" ]]; then
        # Present but empty or too short: replace it.
        mv -f "${tmp}" "${TOKEN_FILE}"
        log WARN "Replaced an invalid CDP token in ${TOKEN_FILE}. Restart the Norish add-on."
    elif ln "${tmp}" "${TOKEN_FILE}" 2>/dev/null; then
        log INFO "Generated a new CDP token in ${TOKEN_FILE}"
    fi
    rm -f "${tmp}"
}

ensure_token
OBSCURA_CDP_TOKEN="$(read_token)"
if (( ${#OBSCURA_CDP_TOKEN} < 32 )); then
    log ERROR "No valid CDP token in ${TOKEN_FILE} (needs at least 32 characters)."
    exit 1
fi
export OBSCURA_CDP_TOKEN

log INFO "Starting Obscura ${OBSCURA_UPSTREAM_TAG:-} on port 9222"

# Same command as the upstream image's ENTRYPOINT. --allow-private-network is
# deliberately absent: Obscura blocks loopback, RFC1918 and link-local targets
# so an import cannot reach your home network.
exec /obscura serve --host 0.0.0.0 --port 9222 --stealth

#!/usr/bin/env bash
# obsidian-agent.sh – Wrapper around agentbox for Obsidian Vault access
# Usage: obsidian-agent [args...]
# All arguments are forwarded to agentbox.

set -euo pipefail

CONFIG_DIR="$HOME/.obsidian-agent"
CONFIG_FILE="$CONFIG_DIR/config"

# --- Helper functions ---

die() {
    echo "Fehler: $1" >&2
    exit 1
}

# --- Load configuration ---

if [[ ! -f "$CONFIG_FILE" ]]; then
    die "Konfiguration nicht gefunden. Bitte zuerst setup.sh ausführen.
    Siehe: https://github.com/larsl/obsidian-agentbox"
fi

# Source config file (sets VAULT_PATH and AGENTBOX_PATH)
# shellcheck source=/dev/null
source "$CONFIG_FILE"

if [[ -z "${VAULT_PATH:-}" ]]; then
    die "VAULT_PATH ist nicht in $CONFIG_FILE gesetzt. Bitte setup.sh erneut ausführen."
fi

if [[ -z "${AGENTBOX_PATH:-}" ]]; then
    die "AGENTBOX_PATH ist nicht in $CONFIG_FILE gesetzt. Bitte setup.sh erneut ausführen."
fi

# --- Validate paths ---

if [[ ! -d "$VAULT_PATH" ]]; then
    die "Vault-Ordner nicht gefunden: $VAULT_PATH
    Wurde der Ordner verschoben? Bitte setup.sh erneut ausführen."
fi

AGENTBOX_BIN="$AGENTBOX_PATH/agentbox"

if [[ ! -x "$AGENTBOX_BIN" ]]; then
    die "agentbox nicht gefunden oder nicht ausführbar: $AGENTBOX_BIN
    Prüfe ob agentbox korrekt installiert ist."
fi

# --- Launch agentbox with vault mounted ---

exec "$AGENTBOX_BIN" --add-dir "$VAULT_PATH" "$@"

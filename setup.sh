#!/usr/bin/env bash
# setup.sh – One-time setup for Obsidian Agent Box
# Checks prerequisites, configures paths, and prepares the vault.
# Safe to run multiple times (idempotent).

set -euo pipefail

# --- Configuration ---

CONFIG_DIR="$HOME/.obsidian-agent"
CONFIG_FILE="$CONFIG_DIR/config"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_CLAUDE_TEMPLATE="$SCRIPT_DIR/vault-claude.md"

# --- Helper functions ---

info() {
    echo ""
    echo "==> $1"
}

success() {
    echo "    OK: $1"
}

warn() {
    echo "    HINWEIS: $1"
}

die() {
    echo ""
    echo "FEHLER: $1" >&2
    exit 1
}

ask() {
    local prompt="$1"
    local default="${2:-}"
    if [[ -n "$default" ]]; then
        read -r -p "    $prompt [$default]: " answer
        echo "${answer:-$default}"
    else
        read -r -p "    $prompt: " answer
        echo "$answer"
    fi
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-j}"
    local yn
    if [[ "$default" == "j" ]]; then
        read -r -p "    $prompt [J/n]: " yn
        yn="${yn:-j}"
    else
        read -r -p "    $prompt [j/N]: " yn
        yn="${yn:-n}"
    fi
    [[ "$yn" =~ ^[jJyY]$ ]]
}

# --- Step 1: Check prerequisites ---

info "Prüfe Voraussetzungen..."

# Check Docker
if command -v docker &>/dev/null; then
    success "Docker ist installiert."
else
    die "Docker ist nicht installiert.
    Bitte installiere Docker Desktop: https://www.docker.com/products/docker-desktop/
    Nach der Installation starte dieses Skript erneut."
fi

# Check Docker is running
if docker info &>/dev/null 2>&1; then
    success "Docker läuft."
else
    die "Docker ist installiert, aber nicht gestartet.
    Bitte starte Docker Desktop und führe dieses Skript erneut aus."
fi

# Check Bash version
BASH_MAJOR="${BASH_VERSINFO[0]}"
if [[ "$BASH_MAJOR" -ge 4 ]]; then
    success "Bash $BASH_VERSION (4.0+ benötigt)."
else
    die "Bash $BASH_VERSION ist zu alt (4.0+ benötigt).
    Auf macOS kannst du eine neuere Version installieren mit:
        brew install bash
    Danach starte das Skript mit:
        /opt/homebrew/bin/bash setup.sh"
fi

# Check for git or curl (need at least one to download agentbox)
HAS_GIT=false
if command -v git &>/dev/null; then
    HAS_GIT=true
    success "Git ist installiert."
else
    warn "Git ist nicht installiert (optional – Download geht auch ohne)."
fi

if ! command -v curl &>/dev/null; then
    if [[ "$HAS_GIT" != true ]]; then
        die "Weder git noch curl gefunden. Bitte installiere mindestens eines davon."
    fi
fi

# --- Step 2: Configure agentbox ---

info "Konfiguriere agentbox..."

AGENTBOX_REPO_URL="https://github.com/fletchgqc/agentbox"
AGENTBOX_ZIP_URL="$AGENTBOX_REPO_URL/archive/refs/heads/main.zip"
DEFAULT_AGENTBOX_PATH="$HOME/agentbox"
AGENTBOX_PATH=""

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    EXISTING_AGENTBOX="${AGENTBOX_PATH:-}"
    EXISTING_VAULT="${VAULT_PATH:-}"
    AGENTBOX_PATH=""
    VAULT_PATH=""
fi

# Check if agentbox already exists
if [[ -n "${EXISTING_AGENTBOX:-}" ]] && [[ -d "${EXISTING_AGENTBOX:-}" ]]; then
    echo "    agentbox wurde bereits konfiguriert: $EXISTING_AGENTBOX"
    if ask_yes_no "Diesen Pfad beibehalten?"; then
        AGENTBOX_PATH="$EXISTING_AGENTBOX"
    fi
fi

if [[ -z "$AGENTBOX_PATH" ]]; then
    # Ask where to clone/find agentbox
    if [[ -d "$DEFAULT_AGENTBOX_PATH" ]] && [[ -x "$DEFAULT_AGENTBOX_PATH/agentbox" ]]; then
        echo "    agentbox gefunden in: $DEFAULT_AGENTBOX_PATH"
        AGENTBOX_PATH="$DEFAULT_AGENTBOX_PATH"
    else
        echo "    agentbox wird benötigt ($AGENTBOX_REPO_URL)."
        echo ""
        echo "    Optionen:"
        echo "    1) Automatisch nach $DEFAULT_AGENTBOX_PATH herunterladen"
        echo "    2) Pfad zu bestehendem agentbox angeben"
        echo ""
        choice=$(ask "Deine Wahl (1 oder 2)" "1")

        if [[ "$choice" == "1" ]]; then
            if [[ -d "$DEFAULT_AGENTBOX_PATH" ]]; then
                warn "Ordner $DEFAULT_AGENTBOX_PATH existiert bereits."
                if [[ "$HAS_GIT" == true ]] && [[ -d "$DEFAULT_AGENTBOX_PATH/.git" ]]; then
                    echo "    Aktualisiere via git pull..."
                    git -C "$DEFAULT_AGENTBOX_PATH" pull --ff-only 2>/dev/null || true
                fi
            elif [[ "$HAS_GIT" == true ]]; then
                echo "    Klone agentbox..."
                git clone "$AGENTBOX_REPO_URL.git" "$DEFAULT_AGENTBOX_PATH"
            else
                echo "    Lade agentbox herunter..."
                TMPZIP="$(mktemp /tmp/agentbox-XXXXXX.zip)"
                curl -sL "$AGENTBOX_ZIP_URL" -o "$TMPZIP" || die "Download fehlgeschlagen. Prüfe deine Internetverbindung."
                unzip -qo "$TMPZIP" -d /tmp/agentbox-extract || die "Entpacken fehlgeschlagen."
                mv /tmp/agentbox-extract/agentbox-main "$DEFAULT_AGENTBOX_PATH"
                rm -rf "$TMPZIP" /tmp/agentbox-extract
                chmod +x "$DEFAULT_AGENTBOX_PATH/agentbox"
            fi
            AGENTBOX_PATH="$DEFAULT_AGENTBOX_PATH"
        elif [[ "$choice" == "2" ]]; then
            AGENTBOX_PATH=$(ask "Pfad zu agentbox")
            # Expand tilde
            AGENTBOX_PATH="${AGENTBOX_PATH/#\~/$HOME}"
        else
            die "Ungültige Wahl: $choice"
        fi
    fi
fi

# Validate agentbox
if [[ ! -x "$AGENTBOX_PATH/agentbox" ]]; then
    die "agentbox-Skript nicht gefunden oder nicht ausführbar: $AGENTBOX_PATH/agentbox
    Prüfe ob der Pfad korrekt ist und agentbox korrekt installiert wurde."
fi

success "agentbox: $AGENTBOX_PATH"

# --- Step 3: Configure vault path ---

info "Konfiguriere Obsidian Vault..."

VAULT_PATH=""

if [[ -n "${EXISTING_VAULT:-}" ]] && [[ -d "${EXISTING_VAULT:-}" ]]; then
    echo "    Vault wurde bereits konfiguriert: $EXISTING_VAULT"
    if ask_yes_no "Diesen Pfad beibehalten?"; then
        VAULT_PATH="$EXISTING_VAULT"
    fi
fi

if [[ -z "$VAULT_PATH" ]]; then
    echo "    Wo liegt dein Obsidian Vault?"
    echo "    (Tipp: In Obsidian unter Einstellungen > Über diesen Vault findest du den Pfad)"
    echo ""
    VAULT_PATH=$(ask "Vault-Pfad (z.B. ~/Documents/MeinVault)")

    # Expand tilde
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

    # Remove trailing slash
    VAULT_PATH="${VAULT_PATH%/}"
fi

# Validate vault path
if [[ ! -d "$VAULT_PATH" ]]; then
    die "Ordner nicht gefunden: $VAULT_PATH
    Bitte prüfe den Pfad und versuche es erneut."
fi

# Simple check: does it look like an Obsidian vault?
if [[ -d "$VAULT_PATH/.obsidian" ]]; then
    success "Obsidian Vault erkannt: $VAULT_PATH"
else
    warn "Kein .obsidian-Ordner gefunden in $VAULT_PATH."
    echo "    Das könnte bedeuten, dass der Ordner kein Obsidian Vault ist,"
    echo "    oder dass Obsidian noch nicht damit geöffnet wurde."
    if ! ask_yes_no "Trotzdem fortfahren?" "n"; then
        die "Setup abgebrochen. Bitte prüfe den Vault-Pfad."
    fi
fi

# --- Step 4: Save configuration ---

info "Speichere Konfiguration..."

mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" << EOF
# Obsidian Agent Box – Konfiguration
# Erstellt von setup.sh – kann manuell bearbeitet werden

VAULT_PATH="$VAULT_PATH"
AGENTBOX_PATH="$AGENTBOX_PATH"
EOF

success "Konfiguration gespeichert: $CONFIG_FILE"

# --- Step 5: Copy CLAUDE.md to vault ---

info "Bereite CLAUDE.md für dein Vault vor..."

if [[ ! -f "$VAULT_CLAUDE_TEMPLATE" ]]; then
    die "Template nicht gefunden: $VAULT_CLAUDE_TEMPLATE
    Stelle sicher, dass vault-claude.md im selben Ordner wie setup.sh liegt."
fi

VAULT_CLAUDE="$VAULT_PATH/CLAUDE.md"

if [[ -f "$VAULT_CLAUDE" ]]; then
    warn "CLAUDE.md existiert bereits in deinem Vault."
    echo "    Bestehende Datei: $VAULT_CLAUDE"
    if ask_yes_no "Überschreiben? (Deine Anpassungen gehen verloren)" "n"; then
        cp "$VAULT_CLAUDE_TEMPLATE" "$VAULT_CLAUDE"
        success "CLAUDE.md wurde aktualisiert."
    else
        echo "    CLAUDE.md wurde nicht verändert."
    fi
else
    cp "$VAULT_CLAUDE_TEMPLATE" "$VAULT_CLAUDE"
    success "CLAUDE.md wurde in dein Vault kopiert."
fi

echo "    Du kannst die Datei jetzt in Obsidian öffnen und an dein Vault anpassen."

# --- Step 6: API Key hint ---

info "Fast fertig! Noch ein wichtiger Schritt:"

echo ""
echo "    Claude Code benötigt einen Portkey API-Schlüssel."
echo "    Folge der Anleitung im Confluence, um einen zu erstellen:"
echo "    https://confluence.codecentric.de/spaces/TOOLS/pages/340230181/Portkey"
echo ""
echo "    Erstelle dann die Datei ~/.agentbox/.env mit diesem Inhalt:"
echo ""
echo "        ANTHROPIC_BASE_URL=https://api.portkey.ai"
echo "        ANTHROPIC_API_KEY=dein-portkey-schlüssel"
echo ""

# --- Step 7: Alias setup ---

ALIAS_LINE="alias obsidian-agent=\"$SCRIPT_DIR/obsidian-agent.sh\""
SHELL_RC="$HOME/.zshrc"

if grep -qF "alias obsidian-agent=" "$SHELL_RC" 2>/dev/null; then
    success "Alias 'obsidian-agent' ist bereits in $SHELL_RC eingerichtet."
else
    info "Alias einrichten"
    echo ""
    echo "    Damit du einfach 'obsidian-agent' im Terminal tippen kannst,"
    echo "    kann ein Alias in deiner $SHELL_RC eingerichtet werden."
    echo ""
    if ask_yes_no "Alias jetzt einrichten?"; then
        echo "$ALIAS_LINE" >> "$SHELL_RC"
        success "Alias wurde zu $SHELL_RC hinzugefügt."
        echo "    Wird beim nächsten Terminal-Fenster aktiv, oder jetzt mit: source $SHELL_RC"
    else
        echo "    Kein Problem. Du kannst es später manuell nachholen:"
        echo ""
        echo "        echo '$ALIAS_LINE' >> $SHELL_RC"
        echo ""
    fi
fi

# --- Done ---

info "Setup abgeschlossen!"

echo ""
echo "    So startest du Claude Code mit deinem Vault:"
echo ""
if grep -qF "alias obsidian-agent=" "$SHELL_RC" 2>/dev/null; then
    echo "        obsidian-agent"
else
    echo "        $SCRIPT_DIR/obsidian-agent.sh"
fi
echo ""
echo "    Viel Spass!"
echo ""

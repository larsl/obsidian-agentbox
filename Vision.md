# Obsidian Agent Box – Projekt-Instruktionen

## Projektziel

Baue ein einfach teilbares Setup, das Kollegen ermöglicht, Claude Code in einem Docker-Container zu nutzen, um mit ihrem lokalen Obsidian Vault zu arbeiten – ohne Claude Code Vollzugriff auf ihr System zu geben.

Das Projekt baut auf [agentbox](https://github.com/fletchgqc/agentbox) auf, einem bestehenden Docker-Setup für isolierte Claude Code Nutzung.

## Zielgruppe

- Agile Coaches, Berater, Wissensarbeiter (keine Entwickler)
- macOS-Nutzer (Apple-Ökosystem)
- Obsidian-Nutzer mit individuellen Vault-Strukturen
- Technisches Niveau: können ein Terminal öffnen und Befehle kopieren, aber keine Docker-Expertise

## Architektur

```
Host-System (macOS)
├── Obsidian Vault (~/Documents/ObsidianVault o.ä.)
│   └── wird via Docker Volume gemountet
├── agentbox (geklontes Repo)
└── obsidian-agentbox/ ← DIESES PROJEKT
    ├── setup.sh              # Einmaliges Setup-Skript
    ├── obsidian-agent.sh     # Täglicher Start-Befehl (Wrapper um agentbox)
    ├── vault-claude.md       # CLAUDE.md Template für das Vault
    ├── README.md             # Onboarding-Anleitung für Kollegen
    └── examples/
        └── example-prompts.md  # Beispiel-Prompts für typische Obsidian-Aufgaben
```

## Kernkomponenten

### 1. `setup.sh` – Einmaliges Setup

Was das Skript tun soll:
- Prüfen ob Docker installiert und gestartet ist
- Prüfen ob Bash 4.0+ vorhanden ist (macOS shipped mit 3.2)
- agentbox klonen falls nicht vorhanden (oder Pfad abfragen)
- Vault-Pfad interaktiv abfragen und validieren (existiert der Ordner?)
- Konfigurationsdatei anlegen (`~/.obsidian-agent/config`) mit Vault-Pfad und agentbox-Pfad
- `vault-claude.md` ins Vault-Root kopieren als `CLAUDE.md` (mit Bestätigung, falls bereits vorhanden)
- Hinweis ausgeben, dass `ANTHROPIC_API_KEY` als Umgebungsvariable gesetzt sein muss oder in `.env` im Vault hinterlegt werden kann

Wichtig:
- Interaktiv und freundlich – erkläre jeden Schritt kurz
- Fehler abfangen und verständliche Meldungen ausgeben
- Kein `sudo` erforderlich
- Idempotent: kann mehrfach ausgeführt werden ohne Schaden

### 2. `obsidian-agent.sh` – Wrapper-Skript

Ein dünner Wrapper um den `agentbox`-Befehl:
- Liest Vault-Pfad und agentbox-Pfad aus `~/.obsidian-agent/config`
- Ruft agentbox auf mit `--add-dir <vault-pfad>`
- Leitet alle zusätzlichen CLI-Argumente an agentbox weiter (z.B. `-c` für continue)
- Setzt das Working Directory auf das Vault

Nutzung soll so einfach sein wie:
```bash
obsidian-agent           # Startet Claude Code mit Vault-Zugriff
obsidian-agent -c        # Letzte Session fortsetzen
```

### 3. `vault-claude.md` – CLAUDE.md Template für das Vault

Dies ist die Datei, die Claude Code innerhalb des Containers als Kontext bekommt. Sie soll enthalten:

**Rollenanweisung:**
- Du bist ein Assistent für Wissensmanagement in Obsidian
- Du arbeitest mit Markdown-Dateien in einem Obsidian Vault
- Du verstehst Obsidian-Konventionen (Wikilinks, Properties/Frontmatter, Tags, Dataview)

**Vault-Konventionen (als Platzhalter, die der Nutzer anpasst):**
- Ordnerstruktur-Beschreibung (Platzhalter mit Beispiel: `10-Daily/`, `20-Projects/`, etc.)
- Template-Konventionen
- Namenskonventionen für Dateien
- Genutzte Plugins (Platzhalter-Liste)
- Frontmatter/Properties-Schema

**Verhaltensregeln:**
- Erstelle keine Dateien ohne explizite Aufforderung
- Ändere keine bestehenden Dateien ohne Bestätigung
- Nutze immer relative Wikilinks `[[Seitenname]]` statt absolute Pfade
- Respektiere bestehendes Frontmatter, ergänze es nur
- Bei Templates: Verwende Templater-Syntax `<% %>` nur wenn in den Konventionen angegeben
- Schlage Verbesserungen vor, setze sie aber nicht eigenmächtig um

**Typische Aufgaben (als Orientierung):**
- Neue Notizen nach Template erstellen
- Bestehende Notizen reorganisieren oder verlinken
- Dataview-Queries schreiben oder debuggen
- Frontmatter ergänzen oder korrigieren
- Inhalte zusammenfassen oder aufbereiten
- Vault-weite Suche und Analyse

### 4. `README.md` – Onboarding-Anleitung

Zielgruppengerecht geschrieben (keine Dev-Vorkenntnisse):

**Struktur:**
1. Was ist das? (2-3 Sätze)
2. Was brauchst du? (Voraussetzungen-Checkliste)
3. Einrichtung Schritt für Schritt
4. Tägliche Nutzung
5. Dein Vault anpassen (CLAUDE.md editieren)
6. Fehlerbehebung (FAQ-Stil)
7. Wie es funktioniert (optionaler technischer Hintergrund)

**Ton:** Freundlich, ermutigend, ohne Fachjargon wo vermeidbar. Wenn technische Begriffe nötig sind, kurz erklären.

### 5. `examples/example-prompts.md` – Beispiel-Prompts

Sammlung von Copy-Paste-fähigen Prompts für typische Obsidian-Aufgaben:
- "Erstelle eine neue Meeting-Notiz für heute mit [Teilnehmer] zum Thema [X]"
- "Finde alle Notizen die mit dem Projekt [X] verlinkt sind und erstelle eine Zusammenfassung"
- "Schreibe eine Dataview-Query die alle offenen Tasks aus dem Ordner 20-Projects zeigt"
- "Prüfe meine Daily Note von heute auf fehlende Verlinkungen"
- "Reorganisiere die Tags in meinem Vault – zeige mir erst eine Übersicht"

## Technische Constraints

- **Sprache der Codebasis:** Englisch (Kommentare, Variablennamen)
- **Sprache der Nutzer-Dokumentation:** Deutsch
- **Shell:** Bash (kompatibel mit Bash 4.0+, teste keine zsh-spezifischen Features)
- **Keine zusätzlichen Dependencies** über agentbox hinaus
- **Kein sudo** – alles muss als normaler User laufen
- **Vault-Sync-Kompatibilität:** Das Setup darf keine Dateien im Vault anlegen die Sync-Konflikte verursachen (z.B. keine Lock-Files, keine `.git`-Initialisierung im Vault)

## Qualitätskriterien

- Ein Kollege ohne Docker-Erfahrung kann mit der README allein das Setup durchführen
- `setup.sh` gibt bei jedem Fehler einen verständlichen Hinweis was zu tun ist
- `obsidian-agent.sh` startet in unter 10 Sekunden (nach initialem Docker-Build)
- Die CLAUDE.md im Vault ist sofort nützlich, auch ohne Anpassungen
- Alle Skripte sind mit `shellcheck` fehlerfrei

## Reihenfolge der Umsetzung

1. `vault-claude.md` – das Herzstück, bestimmt die Nutzererfahrung
2. `obsidian-agent.sh` – der Wrapper, technisch simpel aber muss robust sein
3. `setup.sh` – das Onboarding, muss fehlertolerant sein
4. `README.md` – die Anleitung, baut auf den fertigen Skripten auf
5. `examples/example-prompts.md` – die Inspiration für Nutzer
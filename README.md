# Obsidian Agent Box

Nutze Claude Code als KI-Assistenten für dein Obsidian Vault – sicher isoliert in einem Docker-Container, ohne Claude Zugriff auf dein ganzes System zu geben.

## Was ist das?

Obsidian Agent Box gibt dir einen KI-Assistenten, der direkt mit deinen Obsidian-Notizen arbeiten kann: Notizen erstellen, reorganisieren, Dataview-Queries schreiben, Zusammenfassungen erstellen und vieles mehr. Die KI läuft dabei in einer abgeschotteten Umgebung (Docker-Container) und hat nur Zugriff auf deinen Vault-Ordner – nicht auf deine E-Mails, Dokumente oder andere Dateien.

Das Projekt basiert auf [agentbox](https://github.com/fletchgqc/agentbox), einem bestehenden Setup für isolierte Claude Code Nutzung.

## Was brauchst du?

Bevor du loslegst, prüfe diese Checkliste:

- [ ] **macOS** (Apple-Rechner)
- [ ] **Docker Desktop** installiert und gestartet ([Download](https://www.docker.com/products/docker-desktop/))
- [ ] **Anthropic API-Schlüssel** ([hier erstellen](https://console.anthropic.com/))
- [ ] **Ein Obsidian Vault** auf deinem Rechner

### Docker Desktop installieren

Falls du Docker noch nicht hast:

1. Gehe zu [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. Lade die Version für **Mac with Apple Chip** (oder Intel, je nach Rechner) herunter
3. Öffne die heruntergeladene `.dmg`-Datei und ziehe Docker in den Programme-Ordner
4. Starte Docker Desktop aus dem Programme-Ordner
5. Warte bis das Docker-Symbol in der Menüleiste erscheint (kleiner Wal)

### API-Schlüssel erstellen

1. Gehe zu [console.anthropic.com](https://console.anthropic.com/)
2. Erstelle ein Konto oder melde dich an
3. Gehe zu **API Keys** und erstelle einen neuen Schlüssel
4. Kopiere den Schlüssel – du brauchst ihn gleich

## Einrichtung

Öffne das **Terminal** (findest du über Spotlight mit `Cmd + Leertaste`, dann "Terminal" eingeben).

### 1. Projekt herunterladen

```bash
git clone https://github.com/larsl/obsidian-agentbox.git ~/obsidian-agentbox
```

### 2. Setup ausführen

```bash
cd ~/obsidian-agentbox
bash setup.sh
```

Das Setup-Skript führt dich durch die Einrichtung:
- Es prüft ob Docker läuft
- Es lädt die benötigte Software (agentbox) herunter
- Es fragt nach dem Pfad zu deinem Obsidian Vault
- Es bereitet dein Vault für die KI-Nutzung vor

### 3. API-Schlüssel hinterlegen

Erstelle die Datei `~/.agentbox/.env` mit deinem API-Schlüssel:

```bash
mkdir -p ~/.agentbox
echo "ANTHROPIC_API_KEY=dein-schlüssel-hier" > ~/.agentbox/.env
```

Ersetze `dein-schlüssel-hier` mit dem Schlüssel aus Schritt "API-Schlüssel erstellen".

### 4. Alias einrichten (optional, aber empfohlen)

Damit du einfach `obsidian-agent` tippen kannst statt dem vollen Pfad:

```bash
echo 'alias obsidian-agent="$HOME/obsidian-agentbox/obsidian-agent.sh"' >> ~/.zshrc
source ~/.zshrc
```

## Tägliche Nutzung

### Claude starten

```bash
obsidian-agent
```

Beim ersten Start baut Docker ein Image – das dauert ein paar Minuten. Danach startet es in Sekunden.

### Letzte Session fortsetzen

```bash
obsidian-agent -c
```

### Beenden

Tippe `/exit` oder drücke `Ctrl+C` im Claude-Fenster.

### Beispiel-Prompts

Eine Sammlung nützlicher Prompts findest du in der Datei `examples/example-prompts.md`.

## Dein Vault anpassen

Bei der Einrichtung wurde eine Datei `CLAUDE.md` in dein Vault kopiert. Diese Datei sagt der KI, wie dein Vault aufgebaut ist. **Öffne sie in Obsidian und passe sie an:**

- **Ordnerstruktur:** Beschreibe deine tatsächlichen Ordner
- **Namenskonventionen:** Wie benennst du deine Dateien?
- **Frontmatter:** Welche Properties nutzt du?
- **Plugins:** Welche Obsidian-Plugins sind für die KI relevant?

Je besser die `CLAUDE.md` dein Vault beschreibt, desto hilfreicher ist die KI.

## Fehlerbehebung

### "Docker ist nicht gestartet"

Starte Docker Desktop aus dem Programme-Ordner. Warte bis das Wal-Symbol in der Menüleiste erscheint.

### "Bash ist zu alt"

macOS liefert eine alte Bash-Version mit. Installiere eine neuere:

```bash
brew install bash
```

Falls `brew` nicht installiert ist, folge der Anleitung auf [brew.sh](https://brew.sh/).

Danach starte das Setup mit:

```bash
/opt/homebrew/bin/bash setup.sh
```

### "Konfiguration nicht gefunden"

Du musst zuerst `setup.sh` ausführen (siehe Abschnitt "Einrichtung").

### "Vault-Ordner nicht gefunden"

Der konfigurierte Vault-Pfad existiert nicht mehr. Mögliche Ursachen:
- Der Vault wurde verschoben oder umbenannt
- Eine externe Festplatte ist nicht angeschlossen

Lösung: Führe `setup.sh` erneut aus und gib den aktuellen Pfad an.

### Claude antwortet nicht oder gibt Fehler aus

- Prüfe ob dein API-Schlüssel korrekt in `~/.agentbox/.env` hinterlegt ist
- Prüfe ob du noch API-Guthaben hast unter [console.anthropic.com](https://console.anthropic.com/)

### Der erste Start dauert sehr lange

Das ist normal. Beim ersten Start wird ein Docker-Image gebaut (ca. 2-5 Minuten). Alle weiteren Starts sind schnell.

## Wie es funktioniert (technischer Hintergrund)

Dieser Abschnitt ist optional – du brauchst das nicht zu wissen, um das Tool zu nutzen.

**Docker** ist eine Software, die isolierte Umgebungen ("Container") auf deinem Rechner erstellt. Stell dir vor, Claude Code läuft in einem abgeschotteten Raum und kann nur durch ein Fenster auf deinen Vault-Ordner schauen – aber nicht auf den Rest deines Computers.

**agentbox** ist ein Open-Source-Projekt, das Claude Code in so einem Container startet. Es kümmert sich um die Docker-Konfiguration.

**Obsidian Agent Box** (dieses Projekt) ist ein dünner Wrapper um agentbox, der drei Dinge hinzufügt:

1. Ein einfaches Setup-Skript für die Einrichtung
2. Eine vorkonfigurierte `CLAUDE.md`-Datei, die Claude beibringt, wie es mit Obsidian-Vaults arbeiten soll
3. Einen Startbefehl, der deinen Vault automatisch in den Container einbindet

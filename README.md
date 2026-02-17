# Obsidian Agent Box

Ein codecentric-internes Setup, um Claude Code als KI-Assistenten für dein Obsidian Vault zu nutzen – sicher isoliert in einem Docker-Container, ohne Claude Zugriff auf dein ganzes System zu geben.

## Was ist das?

Obsidian Agent Box gibt dir einen KI-Assistenten, der direkt mit deinen Obsidian-Notizen arbeiten kann: Notizen erstellen, reorganisieren, Dataview-Queries schreiben, Zusammenfassungen erstellen und vieles mehr. Die KI läuft dabei in einer abgeschotteten Umgebung (Docker-Container) und hat nur Zugriff auf deinen Vault-Ordner – nicht auf deine E-Mails, Dokumente oder andere Dateien.

Der API-Zugang läuft über das codecentric Portkey-Setup – du brauchst keinen eigenen Anthropic-Account.

Das Projekt basiert auf [agentbox](https://github.com/fletchgqc/agentbox) von [John Fletcher](https://github.com/fletchgqc), einem Open-Source-Setup für isolierte Claude Code Nutzung.

## Was brauchst du?

Bevor du loslegst, prüfe diese Checkliste:

- [ ] **macOS** (Apple-Rechner)
- [ ] **Docker Desktop** installiert und gestartet ([Download](https://www.docker.com/products/docker-desktop/))
- [ ] **Obsidian** installiert mit einem Vault auf deinem Rechner
- [ ] **Obsidian Terminal-Plugin** (wird in Obsidian installiert – siehe Anleitung unten)
- [ ] **Portkey API-Schlüssel** (siehe [Portkey-Anleitung im Confluence](https://confluence.codecentric.de/spaces/TOOLS/pages/340230181/Portkey))

### Obsidian installieren und Vault erstellen

[Obsidian](https://obsidian.md/) ist eine App für Notizen, die mit einfachen Markdown-Dateien arbeitet. Alle Notizen liegen in einem Ordner auf deinem Rechner – dem sogenannten "Vault". Es gibt keinen Cloud-Zwang, deine Daten gehören dir.

Falls du Obsidian noch nicht nutzt:

1. Lade Obsidian herunter: [obsidian.md](https://obsidian.md/)
2. Installiere und starte die App
3. Wähle **Create new vault** (Neuen Vault erstellen)
4. Gib deinem Vault einen Namen (z.B. "Notizen") und wähle einen Speicherort (z.B. `~/Documents/Notizen`)
5. Klicke auf **Create**

Obsidian legt einen Ordner mit einem `.obsidian`-Unterordner an. **Merke dir den Pfad zu diesem Ordner** – du brauchst ihn bei der Einrichtung. Den Pfad findest du jederzeit in Obsidian unter **Einstellungen > Allgemein > Vault-Pfad** (bzw. **Settings > General > Vault path**).

Falls du Obsidian bereits nutzt, ist dein Vault einfach der Ordner, den du beim Öffnen der App auswählst.

### Docker Desktop installieren

Falls du Docker noch nicht hast:

1. Gehe zu [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
2. Lade die Version für **Mac with Apple Chip** (oder Intel, je nach Rechner) herunter
3. Öffne die heruntergeladene `.dmg`-Datei und ziehe Docker in den Programme-Ordner
4. Starte Docker Desktop aus dem Programme-Ordner
5. Warte bis das Docker-Symbol in der Menüleiste erscheint (kleiner Wal)

### Portkey API-Schlüssel erstellen

Folge der [Portkey-Anleitung im Confluence](https://confluence.codecentric.de/spaces/TOOLS/pages/340230181/Portkey), um einen API-Schlüssel zu erzeugen. Kopiere den Schlüssel – du brauchst ihn gleich.

## Einrichtung

Öffne das **Terminal** (findest du über Spotlight mit `Cmd + Leertaste`, dann "Terminal" eingeben).

### 1. Projekt herunterladen

**Mit Git:**
```bash
git clone https://github.com/larsl/obsidian-agentbox.git ~/obsidian-agentbox
```

**Ohne Git:** Lade das [ZIP-Archiv](https://github.com/larsl/obsidian-agentbox/archive/refs/heads/main.zip) herunter, entpacke es und benenne den Ordner in `obsidian-agentbox` um:

```bash
cd ~
curl -sL https://github.com/larsl/obsidian-agentbox/archive/refs/heads/main.zip -o obsidian-agentbox.zip
unzip obsidian-agentbox.zip
mv obsidian-agentbox-main obsidian-agentbox
rm obsidian-agentbox.zip
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

Das Setup-Skript fragt auch nach deinem Portkey-Schlüssel und richtet den Befehl `obsidian-agent` ein (dafür wird einmalig dein Mac-Passwort benötigt).

## Tägliche Nutzung

Es gibt zwei Wege, Claude Code zu starten: direkt in Obsidian (empfohlen) oder über ein separates Terminal-Fenster.

### Option A: Direkt in Obsidian (empfohlen)

Mit dem Plugin **Terminal** kannst du Claude Code direkt in Obsidian nutzen – ohne die App zu verlassen.

#### Terminal-Plugin installieren

1. Öffne Obsidian und gehe zu **Einstellungen > Community Plugins**
2. Falls nötig, klicke auf **Eingeschränkter Modus deaktivieren** und bestätige
3. Klicke auf **Durchsuchen** und suche nach **Terminal**
4. Installiere das Plugin von **polyipseity** und aktiviere es

#### Claude Code in Obsidian starten

1. Öffne die Befehlspalette mit `Cmd + P`
2. Tippe **Terminal** und wähle **Terminal: Open Terminal**
3. Im Terminal-Fenster tippe:

```bash
obsidian-agent
```

Claude Code startet jetzt in einem Fenster innerhalb von Obsidian. Du kannst direkt losschreiben – Claude hat Zugriff auf dein Vault, aber auf nichts anderes.

#### Tipps für die Nutzung in Obsidian

- Du kannst das Terminal-Fenster an den unteren Rand oder die Seite ziehen
- Mit `Cmd + P` → **Terminal: Open Terminal** öffnest du jederzeit ein neues Terminal
- Deine Notizen bleiben im Hauptbereich sichtbar, während du unten mit Claude arbeitest

### Option B: Separates Terminal-Fenster

Falls du lieber ein eigenes Terminal-Fenster nutzt:

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

- Prüfe ob dein Portkey-Schlüssel korrekt in `~/.agentbox/.env` hinterlegt ist
- Prüfe ob `ANTHROPIC_BASE_URL=https://api.portkey.ai` ebenfalls in der `.env` steht

### Der erste Start dauert sehr lange

Das ist normal. Beim ersten Start wird ein Docker-Image gebaut (ca. 2-5 Minuten). Alle weiteren Starts sind schnell.

## Wie es funktioniert (technischer Hintergrund)

Dieser Abschnitt ist optional – du brauchst das nicht zu wissen, um das Tool zu nutzen.

**Docker** ist eine Software, die isolierte Umgebungen ("Container") auf deinem Rechner erstellt. Stell dir vor, Claude Code läuft in einem abgeschotteten Raum und kann nur durch ein Fenster auf deinen Vault-Ordner schauen – aber nicht auf den Rest deines Computers.

**[agentbox](https://github.com/fletchgqc/agentbox)** ist ein Open-Source-Projekt von [John Fletcher](https://github.com/fletchgqc), das Claude Code in so einem Container startet. Es kümmert sich um die Docker-Konfiguration.

**Obsidian Agent Box** (dieses Projekt) ist ein dünner Wrapper um agentbox, der drei Dinge hinzufügt:

1. Ein einfaches Setup-Skript für die Einrichtung
2. Eine vorkonfigurierte `CLAUDE.md`-Datei, die Claude beibringt, wie es mit Obsidian-Vaults arbeiten soll
3. Einen Startbefehl, der deinen Vault automatisch in den Container einbindet

## Credits

- **[agentbox](https://github.com/fletchgqc/agentbox)** von [John Fletcher](https://github.com/fletchgqc) – das Docker-Sandboxing, auf dem dieses Projekt aufbaut
- **Portkey-Setup** bereitgestellt durch codecentric

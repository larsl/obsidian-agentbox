# Beispiel-Prompts für Obsidian Agent Box

Diese Prompts kannst du direkt kopieren und in Claude Code einfügen. Ersetze die Platzhalter in `[eckigen Klammern]` mit deinen eigenen Angaben.

## Notizen erstellen

**Meeting-Notiz:**
> Erstelle eine neue Meeting-Notiz für heute mit den Teilnehmern [Anna, Ben, Clara] zum Thema [Quartalsplanung Q2]. Nutze das Format aus meinem Templates-Ordner falls vorhanden, sonst erstelle eine sinnvolle Struktur mit Agenda, Notizen und Action Items.

**Projektnotiz:**
> Erstelle eine neue Projektnotiz für das Projekt [Website-Relaunch]. Die Notiz soll enthalten: Projektziel, beteiligte Personen, Timeline, offene Fragen und nächste Schritte.

**Weekly Review:**
> Erstelle eine Weekly-Review-Notiz für diese Woche. Fasse zusammen, was in meinen Daily Notes der letzten 7 Tage steht, gruppiert nach Projekten und Themen.

## Vault analysieren

**Überblick verschaffen:**
> Gib mir einen Überblick über mein Vault: Wie viele Notizen gibt es, wie sind sie auf Ordner verteilt, welche Tags werden am häufigsten verwendet?

**Verwaiste Notizen finden:**
> Finde alle Notizen in meinem Vault, die von keiner anderen Notiz verlinkt werden (verwaiste Notizen). Zeige sie gruppiert nach Ordner.

**Fehlende Verlinkungen:**
> Prüfe meine Daily Note von heute auf Begriffe, die auch als eigene Notizen existieren, aber noch nicht verlinkt sind. Schlage Verlinkungen vor.

**Tag-Analyse:**
> Zeige mir eine Übersicht aller Tags in meinem Vault. Welche werden häufig genutzt, welche nur einmal? Gibt es ähnliche Tags die zusammengelegt werden könnten?

## Dataview-Queries

**Offene Tasks:**
> Schreibe eine Dataview-Query, die alle offenen Tasks (`- [ ]`) aus dem Ordner [20-Projects] anzeigt, sortiert nach Erstellungsdatum.

**Projekt-Dashboard:**
> Erstelle eine Dataview-Query für ein Projekt-Dashboard: Zeige alle Notizen mit dem Tag [#projekt/website-relaunch], gruppiert nach Status (active, waiting, done), mit Erstellungsdatum und letztem Änderungsdatum.

**Letzte Notizen:**
> Schreibe eine Dataview-Query, die die 10 zuletzt bearbeiteten Notizen anzeigt, mit Ordner und Änderungsdatum.

**Meeting-Übersicht:**
> Erstelle eine Dataview-Query, die alle Meeting-Notizen des aktuellen Monats anzeigt, mit Teilnehmern (aus dem Frontmatter) und verknüpften Projekten.

## Notizen reorganisieren

**Ordnerstruktur:**
> Schau dir die Notizen in meinem [00-Inbox]-Ordner an und schlage vor, in welche Ordner sie jeweils verschoben werden sollten. Verschiebe nichts automatisch, zeige nur die Vorschläge.

**Frontmatter ergänzen:**
> Prüfe alle Notizen im Ordner [20-Projects] auf fehlendes oder unvollständiges Frontmatter. Zeige mir eine Liste der Notizen mit Vorschlägen, welche Properties ergänzt werden sollten.

**Notizen verknüpfen:**
> Analysiere die Notizen zum Thema [Agilität] und schlage sinnvolle Verlinkungen zwischen ihnen vor. Welche Notizen behandeln verwandte Themen und sollten aufeinander verweisen?

## Templates

**Template erstellen:**
> Erstelle ein Template für [Buchnotizen] mit folgenden Feldern im Frontmatter: Titel, Autor, Bewertung (1-5), Status (reading/finished/abandoned), Genre. Der Inhalt soll Abschnitte haben für: Zusammenfassung, Kernaussagen, Zitate, Eigene Gedanken.

**Bestehendes Template verbessern:**
> Schau dir mein Template [Templates/Meeting.md] an und schlage Verbesserungen vor. Was könnte ergänzt werden, um Meeting-Notizen nützlicher zu machen?

## Inhalte aufbereiten

**Zusammenfassung:**
> Fasse alle Notizen zusammen, die mit dem Projekt [Teamworkshop] verlinkt sind. Erstelle eine Übersicht mit den wichtigsten Punkten, Entscheidungen und offenen Fragen.

**Braindump strukturieren:**
> Die Notiz [00-Inbox/Gedanken zur Strategie] ist ein unstrukturierter Braindump. Hilf mir, den Inhalt zu strukturieren: Schlage eine Gliederung vor und sortiere die Gedanken thematisch.

**Glossar erstellen:**
> Erstelle ein Glossar mit allen Fachbegriffen, die in meinen Notizen im Ordner [30-Areas/Coaching] vorkommen. Jeder Begriff soll eine kurze Erklärung bekommen und auf die Notizen verlinken, in denen er verwendet wird.

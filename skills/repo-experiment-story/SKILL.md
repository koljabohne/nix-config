---
name: repo-experiment-story
description: Analysiert unstrukturierte Experiment-Repos chronologisch und baut daraus eine Storyline-Präsentation.
---

# Workflow: Vom diffusen Repo zur Experiment-Story

Wenn der Nutzer eine Präsentation über die Experimente in diesem Repository möchte, arbeite STRIKT in diesen 3 Phasen (frage nach Phase 1 und Phase 2 jeweils kurz nach Bestätigung):

## Phase 1: Repo-Archäologie (Chronologie & Artefakte sichern)
1. **Zeitstrahl rekonstruieren:** Nutze `git log --reverse --stat` oder prüfe die Ordner-/Dateistruktur und Zeitstempel, um die echte chronologische Reihenfolge der Experimente zu verstehen.
2. **Beispiele & Ergebnisse extrahieren:** Suche in jedem Experiment-Ordner nach konkreten Inputs, Code-Snippets, Logs, Metriken oder Output-Dateien. Erfinde NIEMALS Zahlen oder Beispiele – nimm echte Beispiele aus dem Code.
3. **Zwischenergebnis zeigen:** Liste mir kurz chronologisch auf, welche Experimente du gefunden hast und welches konkrete Beispiel/Ergebnis du jeweils herausgezogen hast. Stoppe hier und warte auf mein "Go".

## Phase 2: Der Story-Bogen (Das "Warum" zwischen den Experimenten)
Bringe die Chronologie in einen spannenden Spannungsbogen (Iterations-Storytelling), statt sie nur aufzulisten:
- **Ausgangspunkt:** Was war die ursprüngliche Annahme beim 1. Experiment?
- **Die Wendepunkte (Crux):** Warum reichte Experiment N nicht aus? Welches Problem oder welche Erkenntnis hat zu Experiment N+1 geführt? (Zeige auch Sackgassen/Fehler, das macht die Story glaubwürdig!).
- **Synthese:** Was ist das finale Ergebnis heute?
- **Ghost-Deck-Test:** Erstelle die Folien-Gliederung mit *Action Titles* (ganze Aussagesätze als Überschrift, die die Erkenntnis zusammenfassen) und dem geplanten konkreten Code-/Daten-Beispiel pro Folie. Warte auf mein "Go".

## Phase 3: Folien generieren
Nutze erst nach Bestätigung der Gliederung den installierten Präsentations-Skill (z. B. `academic-pptx`, `pptx` oder `frontend-slides`), um das fertige Deck zu rendern.

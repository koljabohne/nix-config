# [Project Name]

[Short 1-2 sentence description of the project and its goals].

## Teilregeln (Sub-Bereiche)

Vor Beginn einer Aufgabe im jeweiligen Teilbereich die entsprechende Datei lesen:

| Bereich / Aufgabe | Zuerst lesen |
|---|---|
| [Domain/Subproject 1: Frontend/UI/App] | `[subproject1]/AGENTS.md` |
| [Domain/Subproject 2: Backend/API/Engine] | `[subproject2]/AGENTS.md` |
| [Domain/Subproject 3: Infrastructure/Ops] | `infra/AGENTS.md` |

*(Bei Single-Context Repositories ohne Teilbereiche kann dieser Abschnitt entfallen).*

## Coding Standards & Architecture

Detaillierte Architekturrichtlinien (strikte Objektorientierung, Interfaces/Protocols, Constructor Injection, Deep Modules und Fakes-vor-Mocks) sind in [`CODING_STANDARDS.md`](CODING_STANDARDS.md) verbindlich definiert. Vor dem Erstellen oder Ändern von Code lesen.

### Wichtigste Invarianten
- **Tech-Stack & Versionen:** [z. B. Python ≥ 3.11 via uv / TypeScript strict].
- **Architektur:** Trenne reinen Core strikt von I/O-Adaptern. Keine globalen Singletons.
- **Sicherheit & Secrets:** Keine Secrets hardcoden. OWASP Top 10 beachten.

## Betrieb und Schutzregeln

- Nichts committen, pushen oder deployen ohne Aufforderung.
- **VERBOT:** Keine `Co-Authored-By`-Zeilen (oder sonstige KI-Attribution) in Commit-Messages oder PR-Beschreibungen.
- Keine produktiven Datenbestände oder Live-Container ungefragt löschen oder neu starten.

## Agent Skills

### Issue Tracker
Issues werden nachvollziehbar dokumentiert. Siehe `docs/agents/issue-tracker.md`.

### Domain Docs
Begriffe und Architekturentscheidungen orientieren sich an `GLOSSARY.md` und `docs/adr/`.


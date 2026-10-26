# Coding Standards

Architecture and coding guidelines for this repository.
Used by developers and agent harnesses (e.g. `/code-review`). Skip what automated linters and typecheckers already enforce; focus on architecture, object-oriented design, and testability.

---

## 1. Paradigma: Objektorientierung & Schnittstellen

### Klassenbasiertes Design
* **Zusammengehörige Logik in Klassen kapseln:** Business-Logik und Zustand gehören in wohldefinierte Klassen (`Service`, `Repository`, `Adapter`, `Pipeline`). Lose Modul-Funktionen sind nur für zustandslose Helpers oder Factory-Einstiegspunkte zulässig.
* **Single Responsibility:** Jede Klasse hat genau eine klare Verantwortung. I/O (z. B. DB/HTTP) und fachliche Bewertung (z. B. Berechnungen/Ranking) gehören niemals in dieselbe Klasse.

### Schnittstellen (Protocols / Interfaces / ABCs)
* **Verträge vor konkreter Implementierung:** An Modulgrenzen und I/O-Schnittstellen (DB, Externe APIs, Search-Backends) werden Schnittstellen als `Protocol` (Python) bzw. `interface` (TypeScript) deklariert.
* **Abhängigkeiten gegen Schnittstellen:** Services erwarten Schnittstellen/Protocols, nicht konkrete Implementierungen.

```python
# ✅ GUT: Schnittstelle als Protocol, Implementierung lose gekoppelt
from typing import Protocol

class DataStore(Protocol):
    async def get_item(self, item_id: str) -> Item | None:
        ...

class ItemService:
    def __init__(self, store: DataStore) -> None:
        self._store = store  # Abhängigkeit wird injiziert
```

### Dependency Injection (Konstruktor-Injektion)
* **Alle Abhängigkeiten im Konstruktor:** Externe Services, Datenbank-Sessions, Clients oder Configs werden im Konstruktor übergeben.
* **Keine globalen Singletons:** Keine Modul-Level-Instanzen mit veränderbarem Zustand.

### Komposition vor Vererbung
* **Bevorzuge Komposition:** Wiederverwendbarkeit wird primär durch das Zusammensetzen von Objekten erreicht.
* **Vererbung nur bei echter Is-A-Beziehung:** Abstrakte Basisklassen (`ABC`) werden nur für echte Template-Methoden eingesetzt.
* **Hierarchietiefe:** Vererbungshierarchien dürfen maximal 1 Ebene tief sein (Basisklasse → Konkrete Klasse).

### Datenmodelle & Wertobjekte
* **Unveränderliche Daten:** Reine Datenträger und Domänenwerte als `@dataclass(frozen=True)` (Python) oder `readonly` Interfaces (TypeScript) modellieren.
* **Systemgrenzen:** Validierungsmodelle (Pydantic / Zod) werden ausschließlich an Systemgrenzen (API Request/Response, Config) eingesetzt.

---

## 2. Modularität & Modultiefe ("Deep Modules")

### Tiefe Module (Kleine Schnittstelle, viel Kapselung)
* **Minimaler öffentlicher Footprint:** Klassen sollen so wenige öffentliche Methoden wie möglich exponieren. Komplexe interne Abläufe werden in privaten Methoden gekapselt.
* **Interface = Test-Oberfläche:** Tests interagieren ausschließlich über die öffentliche Schnittstelle.

### Trennung von Core & Adapter
* **Reine Geschäftslogik (Core):** Domänenlogik muss vollkommen frei von Datenbankabfragen, HTTP-Calls und Event-Loops bleiben (deterministisch und sofort unit-testbar).
* **Adapter an den Rändern:** I/O, Persistenz und Third-Party-Calls liegen in dedizierten Adaptern.

---

## 3. Lesbarkeit & Clean Code

* **Guard Clauses (Early Exit):** Keine Verschachtelungstiefen größer als 2. Behandle Fehler- und Randfälle zuerst und steige frühzeitig per `return` aus.
* **Fokussierte Methoden:** Methoden sollten in der Regel maximal 25–30 Zeilen lang sein.
* **Domänenvokabular:** Verwende strikt die Begriffe aus dem Domänen-Glossar (`GLOSSARY.md` oder `CONTEXT.md`). Keine Synonyme erfinden.
* **Kommentare:** Kommentiere nur das *Warum*, niemals das offensichtliche *Was*.

---

## 4. Test-Standards

### Klassenbasierte Teststruktur
* **Organisation:** Für jede getestete Klasse/Einheit existiert eine entsprechende Testklasse `class Test<Name>:`.
* **Methoden:** Testmethoden heißen `test_<spezifisches_verhalten>`.

### Fakes vor Mocks
* **In-Memory Fakes:** Ersetze externe Adapter (DB, Cache, APIs) durch leichtgewichtige Fakes, die das Interface/Protocol erfüllen, statt tief verschachtelte Mocks (`mock.patch`) zu bauen.
* **Verhalten testen, nicht Aufrufe:** Assertiere den Rückgabewert oder den Zustand nach der Aktion, nicht interne Methodenaufrufe.


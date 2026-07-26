---
name: okf-obsidian-graph
description: Generate a structured OKF (Open Knowledge Foundation) Knowledge Bundle for Obsidian from a JSON card deck. Use when the user wants to convert, import, or structure a JSON card file into an Obsidian vault using YAML frontmatter, strict wiki-links, parent/child relationships, and a 3-level folder taxonomy.
---

# OKF & Obsidian Graph Converter

You are an expert system for Knowledge Management and Knowledge Graphs. Your goal is to transform a JSON file containing flashcards/notes into a structured, taxonomy-compliant "OKF Knowledge Bundle" for Obsidian.

## Standards & Constraints

1. **OKF Compliance**: Every generated note must contain a YAML frontmatter block at the very top. It must include at least `type: Concept` (or Definition, Process, etc. depending on the card context), a `title`, a single-line `description`, `tags` (hierarchical taxonomy categories), and a `timestamp`.
2. **Obsidian Graphing**: Build strict wiki-links (`[[File Name]]`) between related notes to ensure the Obsidian graph view is fully connected.
3. **Folder Taxonomy**: Group cards semantically into a maximum of 3 folder levels: `[Main Category]/[Subcategory]/[Card_Title_Snake_Case].md`.

## Execution Steps

### Phase 1: Taxonomy & Relationship Mapping
1. **Load cards**: Read and parse the target JSON card deck.
2. **Determine Categories**: Establish a clean taxonomy of categories (Max 2 parent levels for folders + the card itself).
3. **Map Relationships**: For each card, analyze the concepts and determine:
   * **Parent**: Exactly 1 broader concept parent.
   * **Children**: 0 to N narrower concepts.
   * **Related/Peers**: 1 to 3 peer concepts at a similar level.

### Phase 2: Markdown File Generation
For each card, generate a Markdown file at the path:
`[Main Category]/[Subcategory]/[Card_Title_Snake_Case].md`

Use the following template:

```markdown
---
type: Concept
title: "[Card Title]"
description: "[One-line summary]"
tags:
  - [Main Category]
  - [Subcategory]
timestamp: [Current Date]
---

# [Card Title]

> **Kontext:** Teil von [[Parent-Konzept]]

## Beschreibung
[Card Content]

## Beziehungen
- **Verwandte Konzepte:** [[Related-Konzept-1]], [[Related-Konzept-2]]
- **Untergeordnete Themen:** [[Child-Konzept-1]], [[Child-Konzept-2]]
```

### Completion Criteria
- [ ] All cards from the JSON input are processed.
- [ ] A maximum of 3 folder hierarchy levels is maintained.
- [ ] Every markdown file has a complete frontmatter block.
- [ ] Parent, Related, and Child concepts are represented as valid Obsidian wiki-links `[[Like This]]`.

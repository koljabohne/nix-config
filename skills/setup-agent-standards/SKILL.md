---
name: setup-agent-standards
description: Scaffold or audit clean 3-tier agent standards (AGENTS.md router, CODING_STANDARDS.md, and scoped sub-rules) for any repository. Run when setting up a new repo or organizing agent guidelines.
disable-model-invocation: true
---

# Setup Agent Standards

Scaffold a clean, token-efficient 3-tier agent architecture in the current repository:

1. **Root Router (`AGENTS.md`)**: A lean routing table for the harness with context pointers and hard invariants (safety, commit rules).
2. **Architecture & Standards (`CODING_STANDARDS.md`)**: Falsifiable rules for software design, interfaces/protocols, deep modules, and robust testing.
3. **Scoped Sub-Rules (`<package>/AGENTS.md`)**: Context-specific rules for distinct domains or services in a monorepo.

This prevents prompt bloat ("context load") on every turn and equips the agent with actionable standards.

---

## Process

### 1. Explore Repository

Examine the current repo to determine structure and tech stack:
- **Monorepo signals**: Multiple packages, subdirectories with separate `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, or Docker compose setups.
- **Primary language & stack**: Python (FastAPI, PyTorch, etc.), TypeScript/JavaScript, Rust, Go, etc.
- **Existing agent files**: Check for `AGENTS.md`, `CODING_STANDARDS.md`, `CONTEXT.md`, `GLOSSARY.md`.

### 2. Present Plan & Confirm

Summarize findings to the user:
- State whether you detected a **Single-Context Repo** or a **Monorepo**.
- List proposed files to create or update.
- Confirm with the user before writing.

### 3. Generate `CODING_STANDARDS.md`

Create `CODING_STANDARDS.md` at the repo root. Include:

- **Design & Interface Discipline**:
  - Encapsulate business logic and state in cohesive modules/classes (`Service`, `Adapter`, `Repository`).
  - Declare boundaries using structural subtyping (`typing.Protocol` in Python, `interface` in TypeScript, traits in Rust) or abstract base classes.
  - **Dependency Injection**: Pass dependencies explicitly. Ban global singletons.
  - **Composition over Inheritance**: Maximum inheritance depth of 1 level (base -> concrete).
  - **Immutable Data**: Value objects and data holders as `@dataclass(frozen=True)`, `readonly`, or immutable types.
- **Deep Modules (John Ousterhout / Matt Pocock)**:
  - Small interface, deep implementation. Minimize public surface area; keep internals private.
  - Separate pure core logic (zero I/O, deterministic) from adapters at the edges (DB, network, file system).
- **Readability & Defensive Coding**:
  - Early exit / guard clauses (maximum nesting depth ≤ 2).
  - Short, single-purpose methods/functions (≤ 25–30 lines).
  - Strict domain vocabulary without ad-hoc synonyms.
- **Testing Standards**:
  - Group tests logically by behavior or class (`class Test<Name>:` or `describe` blocks).
  - Test behavior through the public interface, not internal private details.
  - **Fakes over Mocks**: Use in-memory fakes satisfying the interface instead of brittle mocking chains.

*(Adapt code examples to the repository's primary language).*

### 4. Generate or Update Root Router (`AGENTS.md`)

Keep the file lean to protect the agent's context budget:
- Create or edit `AGENTS.md` in the root directory.
- **Monorepo Routing Table**: If multiple distinct areas exist, add:
  ```markdown
  ## Sub-Domains
  | Domain / Task | Read First |
  |---|---|
  | [Subproject 1 Description] | `[subproject1]/AGENTS.md` |
  | [Subproject 2 Description] | `[subproject2]/AGENTS.md` |

```

* **Coding Standards Pointer**:
```markdown
## Coding Standards & Architecture
Architectural guidelines (Design, Protocols, Dependency Injection, Deep Modules, and Testing) are defined in `CODING_STANDARDS.md`. Read it before creating or modifying code.

```


* **Essential Invariants**: Only keep hard rules that must apply on *every* turn (e.g. security rules, no unprompted destructive git operations, no Co-Authored-By trailers, language versions).

### 5. Generate Scoped Sub-Rules (if Monorepo)

For each distinct package or domain folder, generate `<subfolder>/AGENTS.md`:

* Scope description (what this folder does).
* Link back to root `CODING_STANDARDS.md`.
* Domain-specific invariants (e.g. specific env vars, GPU vs CPU, frontend sanitization, route approvals).
* How to run tests specifically for this subfolder.

### 6. Done

Summarize the created files and remind the user that the system will now automatically enforce these standards based on the `AGENTS.md` routing.

```

<FollowUp label="Soll ich diesen Skill jetzt in deinem System speichern?" query="Ja, bitte nutze den Skill-Creator, um diesen Setup-Skill für mich zu speichern."/>

```
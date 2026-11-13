---
name: a2a-bridge
description: Inter-agent collaboration across providers (Claude, Codex, Antigravity/Gemini, Kimi) — A2A 1.0 messages to running peers and headless cross-provider subagents via `delegate_*`. Loads when the user mentions a2a, peers, another agent, inbox, broadcast/FYI, delegating to Codex/Gemini/Kimi/Claude, a second opinion from another model, or running low on quota.
license: MIT
---

# a2a-bridge — talking to other agents

Three MCP servers connect you to the other coding agents on this machine:

| Server | Use it for |
|---|---|
| `a2a` | Messages to **running** peer sessions (coordination, questions, FYIs) |
| `delegate` | **Headless subagents** on any provider: a self-contained task, a final answer back |
| `quota` | `get_quota()` — remaining 5h/7d limits and prompt-cache state of every provider |

## Pick the right tool

- Need a **result** (review, research, implementation, second opinion from another model)? → `delegate_start` + `delegate_wait`. Works whether or not a peer session is running, and runs in parallel.
- Need to **coordinate with a peer that is already working** (it owns another project, a contract changed, you need something from its domain)? → `a2a_send_message`.

## Delegate (cross-provider subagents)

```
delegate_providers()                                  # installed CLIs + quota left
delegate_start(provider="codex", task="…", readonly=true, dir="…", timeout_min=30) → {id}
delegate_wait(job_id, wait_s=240)                     # call again while state == running
delegate_list() / delegate_cancel(job_id)
```

- Providers: `claude` (Anthropic), `codex` (OpenAI), `agy` (Google Gemini, 1M context — good for huge diffs/logs), `kimi` (Moonshot).
- The subagent sees **none** of your conversation. Write `task` like a brief for a new colleague: goal, relevant files/paths, constraints (don't commit, files not to touch), what to return and in which format.
- `readonly=true` for reviews and research (plan / read-only mode). Without it the subagent may edit files in `dir` — never run two writers on the same files.
- Start independent jobs back to back, then wait on each: they run in parallel.
- Verify what a subagent claims before you report it as fact.
- Nesting is capped (`AGENT_RUN_MAX_DEPTH`, default 2). Same thing from a shell: `agent-run exec codex "…" --readonly`.

## A2A messages (running peers)

- `a2a_list_agents()` — peers with their Agent Card. Names are `<provider>@<project>-<tty>` (e.g. `codex@nix-pts7`); `skills` contain `provider:<name>`; `description` contains the working directory.
- `a2a_send_message(peer_url, text)` creates a task on the peer that stays working until the peer answers with `a2a_complete_task`. Read the answer later with `a2a_get_task(peer_url, task_id)`. Continue a thread with a new message that reuses `context_id`; pass `task_id` only for a task in input-required state.
- Never block your user waiting for a reply. Say "waiting on `<peer>` for X" in your end-of-turn note and continue.
- **Waiting on a peer while idle**: start `a2a-wait --task <peer_url> <task_id>` as a *background* shell command (Claude Code: Bash with `run_in_background`). It returns when the task finishes (exit 0, prints the reply), when a new message reaches your inbox — e.g. the peer asks back (exit 10), or on `--timeout` (default 30m, exit 2). It only peeks at the inbox; read and answer with `a2a_inbox` / `a2a_complete_task`.
- **Asking back**: there is no tool to put a task into input-required. To ask the sender something, send them a new `a2a_send_message` (same `context_id`) and keep your task working; complete it once you have the answer. The sender gets your question in its inbox.
- Do not use `a2a_send_streaming` between agents — its keep-alive does not match an LLM turn.
- Prefix outbound text with your own name from `a2a_whoami()` in brackets.

### Inbound — every turn

Claude gets its inbox injected by a hook before each prompt; messages marked *reply/FYI* answer a request you sent and need no `a2a_complete_task`. Idle agents are woken by a tty nudge only inside tmux (interactive CLIs start in tmux via `agent-tmux`); **call `a2a_inbox()` at the start of each turn** if no hook delivered messages. For each open request:

- **FYI** → mention it to the user, `a2a_complete_task(task_id, "acknowledged")`.
- **Quick question** (≤2 file reads) → answer right away with `a2a_complete_task`.
- **Big request** → `a2a_complete_task(task_id, "queued, will pick up after <X>")`, then continue with the user.

Answer *before* the user's prompt; fold relevant FYIs into your reply.

### Outbound — proactive FYI

Message peers without being asked when your change will surprise them: API/DTO/enum/webhook contract, DB schema, auth (scopes, TTLs, keys), infra (service names, env vars, ports), or "I need X from your domain".

```
[<your-name>] <one-line summary>

Context: <1-3 lines>
Action: <what they need to do, or "FYI">
Refs:   <files / commits>
```

Contract changes → peers whose cwd looks like a client (`client|web|frontend|mobile|app|sdk`); infra → everyone. Not for small edits.

## Quota-aware delegation

Before heavy or repetitive work (large test runs, wide refactors, whole-repo searches), check `get_quota()`. If your 5h remaining is < 20 % or your cache is cold, delegate the bulk to a provider with quota left and keep the coordination yourself.

Protocol details: `references/protocol.md`.

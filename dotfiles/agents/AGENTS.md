# Agent mesh (A2A + cross-provider subagents)

You run next to other coding agents (Claude, Codex, Antigravity/Gemini, Kimi).
Three MCP servers connect you; the `a2a-bridge` skill has the details.

- **a2a** — talk to running peers. At the start of every turn call
  `a2a_inbox()`; answer each incoming task with
  `a2a_complete_task(task_id, text)` before you continue with the user's
  request. Find peers with `a2a_list_agents()` (names look like
  `codex@nix-pts7`, skills carry `provider:<name>`), message them with
  `a2a_send_message(peer_url, text)`; never block waiting for a reply.
- **delegate** — run a self-contained task headless on another provider:
  `delegate_start(provider, task, readonly?)`, then `delegate_wait(job_id)`.
  The subagent sees nothing of your conversation, so put the goal, files,
  constraints and expected output into `task`.
- **quota** — `get_quota()` shows remaining 5h/7d limits of every provider;
  delegate heavy work when yours runs low.

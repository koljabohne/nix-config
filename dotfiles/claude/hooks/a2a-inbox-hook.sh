#!/usr/bin/env bash
# a2a-inbox-hook.sh — UserPromptSubmit hook for Claude Code.
# Drains the inbox of *this* Claude process (written by `a2abridge bridge`
# into ~/.a2abridge/state/<claude-pid>/inbox.json, see scripts/a2a-bridge)
# and adds quota / prompt-cache alerts.
#
# Emits JSON with `hookSpecificOutput.additionalContext` so notifications
# surface directly inside the agent's turn context. A hook must never break
# the user's prompt, so every failure exits 0 silently.

set -uo pipefail
command -v python3 >/dev/null 2>&1 || exit 0

python3 - "$HOME/.a2abridge/state" "$HOME/.claude/quota_cache.json" <<'PY' 2>/dev/null || exit 0
import json, os, sys, time

state_root, quota_path = sys.argv[1], sys.argv[2]
out = []

def ppid(pid):
    try:
        with open(f"/proc/{pid}/stat") as f:
            return int(f.read().rsplit(")", 1)[1].split()[1])
    except OSError:
        import subprocess
        r = subprocess.run(["ps", "-o", "ppid=", "-p", str(pid)], capture_output=True, text=True).stdout.strip()
        return int(r) if r.isdigit() else 0

# 1. Inbox of the nearest ancestor that owns a bridge state dir (the claude process).
inbox = None
pid = os.getppid()
for _ in range(8):
    if pid <= 1:
        break
    cand = os.path.join(state_root, str(pid), "inbox.json")
    if os.path.exists(cand):
        inbox = cand
        break
    pid = ppid(pid)

msgs = []
if inbox and os.path.getsize(inbox) > 0:
    # Atomic drain: a message the bridge writes after the rename lands in a
    # fresh inbox.json and is picked up next turn instead of being lost.
    draining = inbox + ".draining"
    try:
        if not os.path.exists(draining):
            os.replace(inbox, draining)
        with open(draining) as f:
            msgs = json.load(f) or []
        os.remove(draining)
    except Exception:
        # Unreadable (e.g. caught mid-write): keep .draining, retry next turn.
        msgs = []

def msg_key(m):
    if m.get("messageId"):
        return "m:" + m["messageId"]
    import hashlib
    raw = json.dumps([m.get("taskId"), m.get("from"), m.get("text")], sort_keys=True)
    return "h:" + hashlib.sha1(raw.encode()).hexdigest()

# The bridge keeps its own in-memory inbox and rewrites inbox.json from it, so
# drained messages can reappear: deliver each message only once. Keyed by
# message (not task): a follow-up on an INPUT_REQUIRED task keeps its task id.
if inbox and msgs:
    seen_path = os.path.join(os.path.dirname(inbox), "delivered.json")
    try:
        with open(seen_path) as f:
            seen = json.load(f)
    except Exception:
        seen = []
    fresh = [m for m in msgs if msg_key(m) not in seen]
    seen = (seen + [msg_key(m) for m in fresh])[-500:]
    try:
        with open(seen_path + ".tmp", "w") as f:
            json.dump(seen, f)
        os.replace(seen_path + ".tmp", seen_path)
    except Exception:
        pass
    msgs = fresh

def own_open_tasks(state_dir):
    """Ids of tasks peers opened on this bridge, or None if unknown."""
    import urllib.request
    url = None
    try:
        with open(os.path.join(state_dir, "bridge.log")) as f:
            for line in f:
                if '"a2a server listening"' in line:
                    url = json.loads(line).get("url")
    except Exception:
        return None
    if not url:
        return None
    try:
        req = urllib.request.Request(url.rstrip("/") + "/", method="POST",
            data=json.dumps({"jsonrpc": "2.0", "id": 1, "method": "ListTasks", "params": {}}).encode(),
            headers={"Content-Type": "application/json", "A2A-Version": "1.0"})
        tasks = json.load(urllib.request.urlopen(req, timeout=1)).get("result", {}).get("tasks", [])
    except Exception:
        return None
    return {t.get("id") for t in tasks
            if t.get("status", {}).get("state") in ("TASK_STATE_SUBMITTED", "TASK_STATE_WORKING", "TASK_STATE_INPUT_REQUIRED")}

if msgs:
    open_ids = own_open_tasks(os.path.dirname(inbox))
    out.append(f"You have {len(msgs)} unread A2A message(s):")
    out.append("")
    for m in msgs:
        sender = m.get("from") or "unknown"
        task_id = m.get("taskId", "")
        ctx = m.get("contextId", "")
        text = (m.get("text") or "").replace("\n", " ").strip()
        # A task id that is not open on our own bridge is a reply to a request
        # we sent (or already answered): nothing to complete.
        kind = "" if open_ids is None or task_id in open_ids else " — reply/FYI, no a2a_complete_task needed"
        out.append(f"- **from `{sender}`** (task `{task_id}`{', context `' + ctx + '`' if ctx else ''}{kind}): {text}")
    out.append("")
    out.append("Process each message *before* answering the user: answer open requests with "
               "`a2a_complete_task(task_id, text)` (ask back with `a2a_send_message` if you need input), "
               "then continue with the user's prompt.")
    out.append("")

# 2. Quota alerts (< 15% remaining, or cold cache when > 70% used).
try:
    with open(quota_path) as f:
        q = json.load(f)
    five = q.get("rate_limits", {}).get("five_hour", {})
    used = five.get("used_percentage")
    resets_at = five.get("resets_at")
    warm = q.get("prompt_cache", {}).get("warm", False)
    if resets_at and resets_at < time.time():
        used = None  # window already reset; the cached percentage is stale
    if used is not None and used >= 85:
        rem = max(0, round(100 - used))
        reset = ""
        if resets_at:
            sec = max(0, int(resets_at - time.time()))
            h, m = sec // 3600, (sec % 3600) // 60
            reset = f", resets in {h}h {m}m" if h else f", resets in {m}m"
        out.append(f"⚠️ **Claude Quota Alert**: 5h rate limit is at {round(used)}% ({rem}% remaining{reset}). "
                   "Keep replies concise and delegate heavy subtasks to another provider with `delegate_start` "
                   "(see `delegate_providers` for their quota).")
    if not warm and used is not None and used >= 70:
        out.append("⚠️ **Cache Notice**: Prompt cache is cold. Re-reading context will consume non-cached token budget.")
except Exception:
    pass

text = "\n".join(out).strip()
if text:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": text}}))
PY

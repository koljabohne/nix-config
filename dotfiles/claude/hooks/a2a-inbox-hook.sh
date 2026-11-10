#!/usr/bin/env bash
# a2a-inbox-hook.sh — UserPromptSubmit hook for Claude Code.
# Drains the per-PID inbox file written by `a2abridge bridge` and checks
# real-time quota / prompt-cache thresholds to prevent unexpected aborts.
#
# Emits JSON with `hookSpecificOutput.additionalContext` so notifications
# surface directly inside the agent's turn context.

set -euo pipefail

# A hook must never break the user's prompt: if python3 is unavailable skip silently.
command -v python3 >/dev/null 2>&1 || exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# Find non-empty inbox file.
INBOX=""
for d in "$PROJECT_DIR/.a2a" "$HOME/.a2abridge/state"/*; do
  [ -d "$d" ] || continue
  for f in "$d"/inbox*.json; do
    [ -e "$f" ] || continue
    case "${f##*/}" in
      inbox-*.json)
        pid="${f##*/inbox-}"; pid="${pid%.json}"
        if [ -n "$pid" ] && [ "$pid" -eq "$pid" ] 2>/dev/null && ! kill -0 "$pid" 2>/dev/null; then
          rm -f "$f" 2>/dev/null
          continue
        fi
        ;;
    esac
    [ -s "$f" ] || continue
    INBOX="$f"
    break 2
  done
done

# Render inbox and check quota alerts via python3
RENDERED=$(python3 - "$INBOX" "$HOME/.claude/quota_cache.json" <<'PY' 2>/dev/null
import json, sys, time, os

inbox_path = sys.argv[1] if len(sys.argv) > 1 else ""
quota_path = sys.argv[2] if len(sys.argv) > 2 else ""
out = []

# 1. Process unread A2A inbox messages
if inbox_path and os.path.exists(inbox_path):
    try:
        with open(inbox_path) as f:
            msgs = json.load(f)
        if msgs:
            out.append("You have %d unread A2A message(s):" % len(msgs))
            out.append("")
            for m in msgs:
                sender = m.get("from") or "unknown"
                task_id = m.get("taskId", "")
                text = (m.get("text") or "").replace("\n", " ").strip()
                out.append(f"- **from `{sender}`** (task `{task_id}`): {text}")
            out.append("")
            out.append("Process each message *before* answering the user. Reply with `a2a_complete_task`, then continue with the user's prompt.")
            out.append("")
    except Exception:
        pass

# 2. Check quota alerts (< 15% remaining or cold cache when quota > 70%)
if quota_path and os.path.exists(quota_path):
    try:
        with open(quota_path) as f:
            q = json.load(f)
        rl = q.get("rate_limits", {})
        five = rl.get("five_hour", {})
        used = five.get("used_percentage")
        resets_at = five.get("resets_at")
        cache = q.get("prompt_cache", {})
        cache_warm = cache.get("warm", False)

        alerts = []
        if used is not None and used >= 85:
            rem = max(0, round(100 - used))
            reset_str = ""
            if resets_at:
                sec = max(0, int(resets_at - time.time()))
                h, m = sec // 3600, (sec % 3600) // 60
                reset_str = f"resets in {h}h {m}m" if h > 0 else f"resets in {m}m"
            alerts.append(f"⚠️ **Claude Quota Alert**: 5h rate limit is at {round(used)}% ({rem}% remaining{', ' + reset_str if reset_str else ''}). Consider keeping replies concise or delegating tasks to Antigravity (AGY) via A2A (`a2a_send_message`).")

        if not cache_warm and used is not None and used >= 70:
            alerts.append("⚠️ **Cache Notice**: Prompt cache is currently cold. Re-reading context will consume standard non-cached token budget.")

        if alerts:
            out.extend(alerts)
            out.append("")
    except Exception:
        pass

if out:
    print("\n".join(out).strip())
PY
)

[ -z "$RENDERED" ] && exit 0

python3 - "$RENDERED" <<'PY'
import json, sys
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": sys.argv[1]
    }
}))
PY

# Drain inbox after successful render.
if [ -n "$INBOX" ] && [ -f "$INBOX" ]; then
  : > "$INBOX"
fi

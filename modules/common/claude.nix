# Claude Code configuration (status line, A2A/quota/delegate MCP, inbox hook, permissions), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  statusLine = {
    type = "command";
    command = "~/.claude/statusline.sh";
    padding = 1;
    refreshInterval = 30;
  };

  mcp = import ./agent-mcp.nix { inherit hostVars; } "claude";

  a2aHook = [
    {
      matcher = "*";
      hooks = [
        {
          command = "${hostVars.home}/.claude/hooks/a2a-inbox-hook.sh";
          type = "command";
        }
      ];
    }
  ];

  # Mesh tools must work without a prompt: in auto mode the classifier
  # otherwise blocks a2a_complete_task and peers wait forever. Starting a
  # subagent (delegate_start) is deliberately left to the permission mode.
  allowedTools = [
    "mcp__a2a"
    "mcp__quota"
    "mcp__delegate__delegate_wait"
    "mcp__delegate__delegate_list"
    "mcp__delegate__delegate_providers"
    "mcp__delegate__delegate_cancel"
  ];
in
{
  home.file.".claude/statusline.sh" = {
    source = ../../dotfiles/claude/statusline.sh;
    executable = true;
  };

  home.file.".claude/hooks/a2a-inbox-hook.sh" = {
    source = ../../dotfiles/claude/hooks/a2a-inbox-hook.sh;
    executable = true;
  };

  home.file.".claude/skills/a2a-bridge" = {
    source = ../../dotfiles/agents/skills/a2a-bridge;
    recursive = true;
  };

  # settings.json and ~/.claude.json are also written by Claude Code itself,
  # so only specific keys are merged in; all other keys are left untouched.
  home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    claudeJson="$HOME/.claude.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.claude"

    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge statusLine, a2a hook and mesh permissions into $settings"
      echo "would merge a2a, quota and delegate MCP into $claudeJson"
    else
      # 1. ~/.claude/settings.json (statusLine, a2a inbox hook, mesh permissions)
      [ -s "$settings" ] || echo '{}' > "$settings"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq \
          --argjson sl '${builtins.toJSON statusLine}' \
          --argjson hook '${builtins.toJSON a2aHook}' \
          --argjson allow '${builtins.toJSON allowedTools}' \
          '.statusLine = $sl
           | .hooks.UserPromptSubmit = (
               [ (.hooks.UserPromptSubmit // [])[]
                 | select([.hooks[]?.command // "" | test("a2a-inbox-hook")] | any | not) ]
               + $hook)
           | .permissions.allow = (((.permissions.allow // []) + $allow) | unique)' \
          "$settings" > "$tmp"; then
        cat "$tmp" > "$settings"   # keep existing permissions
      else
        echo "claude: could not merge settings into $settings" >&2
      fi
      rm -f "$tmp"

      # 2. ~/.claude.json (mcpServers.a2a, .quota, .delegate)
      [ -s "$claudeJson" ] || echo '{}' > "$claudeJson"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --argjson mcp '${builtins.toJSON mcp}' \
          '.mcpServers += $mcp' "$claudeJson" > "$tmp"; then
        cat "$tmp" > "$claudeJson"
      else
        echo "claude: could not merge MCP servers into $claudeJson" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

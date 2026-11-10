# Claude Code configuration (status line, A2A MCP bridge, quota MCP, hooks), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  statusLine = {
    type = "command";
    command = "~/.claude/statusline.sh";
    padding = 1;
    refreshInterval = 30;
  };

  a2aMcp = {
    command = "${hostVars.home}/.a2abridge/bin/a2abridge";
    args = [ "bridge" ];
    env = {
      A2A_DIRECTORY = "http://127.0.0.1:7777";
      A2A_BIND = "127.0.0.1:0";
      A2A_ADVERTISE_HOST = "127.0.0.1";
    };
  };

  quotaMcp = {
    command = "${hostVars.home}/.local/bin/agent-quota";
    args = [ "--mcp" ];
  };

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

  home.file.".claude/skills/a2a-bridge/SKILL.md" = {
    source = ../../dotfiles/claude/skills/a2a-bridge/SKILL.md;
  };

  # settings.json and ~/.claude.json are also written by Claude Code itself,
  # so only specific keys are merged in; all other keys are left untouched.
  home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    claudeJson="$HOME/.claude.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.claude"

    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge statusLine and a2a hook into $settings"
      echo "would merge a2a and quota MCP into $claudeJson"
    else
      # 1. ~/.claude/settings.json (statusLine & a2a inbox hook)
      [ -s "$settings" ] || echo '{}' > "$settings"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq \
          --argjson sl '${builtins.toJSON statusLine}' \
          --argjson hook '${builtins.toJSON a2aHook}' \
          '.statusLine = $sl | .hooks.UserPromptSubmit = $hook' "$settings" > "$tmp"; then
        cat "$tmp" > "$settings"   # keep existing permissions
      else
        echo "claude: could not merge settings into $settings" >&2
      fi
      rm -f "$tmp"

      # 2. ~/.claude.json (mcpServers.a2a & mcpServers.quota)
      [ -s "$claudeJson" ] || echo '{}' > "$claudeJson"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq \
          --argjson a2a '${builtins.toJSON a2aMcp}' \
          --argjson quota '${builtins.toJSON quotaMcp}' \
          '.mcpServers.a2a = $a2a | .mcpServers.quota = $quota' "$claudeJson" > "$tmp"; then
        cat "$tmp" > "$claudeJson"
      else
        echo "claude: could not merge MCP servers into $claudeJson" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

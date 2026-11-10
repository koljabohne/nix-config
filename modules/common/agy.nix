# Antigravity (agy) configuration (status line, A2A MCP bridge, quota MCP), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  statusLine = {
    type = "command";
    command = "~/.gemini/antigravity-cli/statusline.sh";
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
in
{
  home.file.".gemini/antigravity-cli/statusline.sh" = {
    source = ../../dotfiles/agy/statusline.sh;
    executable = true;
  };

  # settings.json and mcp_config.json are also written by Antigravity CLI itself,
  # so only specific keys are merged in; all other keys are left untouched.
  home.activation.agyConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.gemini/antigravity-cli/settings.json"
    mcpConfig="$HOME/.gemini/config/mcp_config.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.gemini/antigravity-cli" "$HOME/.gemini/config"

    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge statusLine into $settings"
      echo "would merge a2a and quota MCP into $mcpConfig"
    else
      # 1. ~/.gemini/antigravity-cli/settings.json (statusLine)
      [ -s "$settings" ] || echo '{}' > "$settings"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --argjson sl '${builtins.toJSON statusLine}' \
          '.statusLine = $sl' "$settings" > "$tmp"; then
        cat "$tmp" > "$settings"   # keep existing permissions
      else
        echo "agy: could not merge statusLine into $settings" >&2
      fi
      rm -f "$tmp"

      # 2. ~/.gemini/config/mcp_config.json (mcpServers.a2a & mcpServers.quota)
      [ -s "$mcpConfig" ] || echo '{"mcpServers":{}}' > "$mcpConfig"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq \
          --argjson a2a '${builtins.toJSON a2aMcp}' \
          --argjson quota '${builtins.toJSON quotaMcp}' \
          '.mcpServers.a2a = $a2a | .mcpServers.quota = $quota' "$mcpConfig" > "$tmp"; then
        cat "$tmp" > "$mcpConfig"
      else
        echo "agy: could not merge MCP servers into $mcpConfig" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

# Antigravity (agy) configuration (status line, A2A, quota and delegate MCP), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  statusLine = {
    type = "command";
    command = "~/.gemini/antigravity-cli/statusline.sh";
    padding = 1;
    refreshInterval = 30;
  };

  mcp = import ./agent-mcp.nix { inherit hostVars; } "agy";
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
      echo "would merge a2a, quota and delegate MCP into $mcpConfig"
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

      # 2. ~/.gemini/config/mcp_config.json (mcpServers.a2a, .quota, .delegate)
      [ -s "$mcpConfig" ] || echo '{"mcpServers":{}}' > "$mcpConfig"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --argjson mcp '${builtins.toJSON mcp}' \
          '.mcpServers += $mcp' "$mcpConfig" > "$tmp"; then
        cat "$tmp" > "$mcpConfig"
      else
        echo "agy: could not merge MCP servers into $mcpConfig" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

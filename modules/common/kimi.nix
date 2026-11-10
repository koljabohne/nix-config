# Kimi Code configuration (A2A MCP bridge and quota MCP), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  a2aMcp = {
    command = "${hostVars.home}/.a2abridge/bin/a2abridge";
    args = [ "bridge" ];
    env = {
      A2A_DIRECTORY = "http://127.0.0.1:7777";
      A2A_BIND = "127.0.0.1:0";
      A2A_ADVERTISE_HOST = "127.0.0.1";
      A2A_NUDGE = "auto";
    };
  };

  quotaMcp = {
    command = "${hostVars.home}/.local/bin/agent-quota";
    args = [ "--mcp" ];
  };
in
{
  # ~/.kimi-code/mcp.json is read by Kimi Code at startup.
  # We merge our servers in non-destructively so manual additions are preserved.
  home.activation.kimiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mcpJson="$HOME/.kimi-code/mcp.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.kimi-code"

    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge a2a and quota MCP into $mcpJson"
    else
      [ -s "$mcpJson" ] || echo '{"mcpServers":{}}' > "$mcpJson"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq \
          --argjson a2a '${builtins.toJSON a2aMcp}' \
          --argjson quota '${builtins.toJSON quotaMcp}' \
          '.mcpServers.a2a = $a2a | .mcpServers.quota = $quota' "$mcpJson" > "$tmp"; then
        cat "$tmp" > "$mcpJson"
      else
        echo "kimi: could not merge MCP servers into $mcpJson" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

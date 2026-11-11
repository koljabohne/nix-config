# Kimi Code configuration (A2A, quota and delegate MCP), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  mcp = import ./agent-mcp.nix { inherit hostVars; } "kimi";
in
{
  # ~/.kimi-code/mcp.json is read by Kimi Code at startup.
  # Our servers are merged in non-destructively so manual additions are preserved.
  home.activation.kimiConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mcpJson="$HOME/.kimi-code/mcp.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.kimi-code"

    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge a2a, quota and delegate MCP into $mcpJson"
    else
      [ -s "$mcpJson" ] || echo '{"mcpServers":{}}' > "$mcpJson"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --argjson mcp '${builtins.toJSON mcp}' \
          '.mcpServers += $mcp' "$mcpJson" > "$tmp"; then
        cat "$tmp" > "$mcpJson"
      else
        echo "kimi: could not merge MCP servers into $mcpJson" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

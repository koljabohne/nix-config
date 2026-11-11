# Codex CLI configuration (A2A, quota and delegate MCP, global AGENTS.md;
# skills come from ~/.agents/skills, which codex reads too), shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  mcp = import ./agent-mcp.nix { inherit hostVars; } "codex";
  python = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);

  # Codex rewrites config.toml itself (model choice, trusted projects, ...):
  # only our mcp_servers entries are replaced, everything else is kept.
  mergeScript = pkgs.writeText "codex-merge-mcp.py" ''
    import json, sys, tomlkit
    path, servers = sys.argv[1], json.loads(sys.argv[2])
    try:
        with open(path) as f:
            doc = tomlkit.parse(f.read())
    except FileNotFoundError:
        doc = tomlkit.document()
    table = doc.setdefault("mcp_servers", tomlkit.table())
    for name, spec in servers.items():
        table[name] = spec
    with open(path, "w") as f:
        f.write(tomlkit.dumps(doc))
  '';
in
{
  home.file.".codex/AGENTS.md".source = ../../dotfiles/agents/AGENTS.md;

  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config="$HOME/.codex/config.toml"
    $DRY_RUN_CMD mkdir -p "$HOME/.codex"
    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge a2a, quota and delegate MCP into $config"
    else
      if ! ${python}/bin/python3 ${mergeScript} "$config" '${builtins.toJSON mcp}'; then
        echo "codex: could not merge MCP servers into $config" >&2
      fi
    fi
    # Superseded by ~/.local/bin/a2a-bridge (scripts/a2a-bridge).
    $DRY_RUN_CMD rm -f "$HOME/.a2abridge/bin/a2abridge-bridge"
  '';
}

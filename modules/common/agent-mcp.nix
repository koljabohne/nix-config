# MCP servers every agent CLI gets (not a module: `import ./agent-mcp.nix { inherit hostVars; } "<provider>"`).
#   a2a      — A2A mesh peer (scripts/a2a-bridge wraps `a2abridge bridge` with
#              per-agent identity and inbox; disabled in headless runs)
#   quota    — 5h/7d quota and prompt-cache telemetry of all providers
#   delegate — headless cross-provider subagents (scripts/agent-run)
{ hostVars }:
provider: {
  a2a = {
    command = "${hostVars.home}/.local/bin/a2a-bridge";
    args = [ "--provider" provider ];
    env = {
      A2A_DIRECTORY = "http://127.0.0.1:7777";
      A2A_BIND = "127.0.0.1:0";
      A2A_ADVERTISE_HOST = "127.0.0.1";
      A2A_NUDGE = "auto";
    };
  };
  quota = {
    command = "${hostVars.home}/.local/bin/agent-quota";
    args = [ "--mcp" ];
  };
  delegate = {
    command = "${hostVars.home}/.local/bin/agent-run";
    args = [ "--mcp" ];
  };
}

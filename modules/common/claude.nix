# Claude Code status line, shared by macOS and Ubuntu.
{ lib, pkgs, ... }:

let
  statusLine = {
    type = "command";
    command = "~/.claude/statusline.sh";
    padding = 1;
    refreshInterval = 30;
  };
in
{
  home.file.".claude/statusline.sh" = {
    source = ../../dotfiles/claude/statusline.sh;
    executable = true;
  };

  # settings.json is also written by Claude Code itself, so only the
  # statusLine key is merged in; all other keys are left untouched.
  home.activation.claudeStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.claude"
    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge statusLine into $settings"
    else
      [ -s "$settings" ] || echo '{}' > "$settings"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --argjson sl '${builtins.toJSON statusLine}' \
          '.statusLine = $sl' "$settings" > "$tmp"; then
        cat "$tmp" > "$settings"   # keep the file's existing mode
      else
        echo "claude: could not merge statusLine into $settings" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

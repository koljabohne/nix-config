# Antigravity (agy) status line, shared by macOS and Ubuntu.
{ lib, pkgs, ... }:

let
  statusLine = {
    type = "command";
    command = "~/.gemini/antigravity-cli/statusline.sh";
    padding = 1;
    refreshInterval = 30;
  };
in
{
  home.file.".gemini/antigravity-cli/statusline.sh" = {
    source = ../../dotfiles/agy/statusline.sh;
    executable = true;
  };

  # settings.json is also written by Antigravity CLI itself, so only the
  # statusLine key is merged in; all other keys are left untouched.
  home.activation.agyStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.gemini/antigravity-cli/settings.json"
    $DRY_RUN_CMD mkdir -p "$HOME/.gemini/antigravity-cli"
    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would merge statusLine into $settings"
    else
      [ -s "$settings" ] || echo '{}' > "$settings"
      tmp="$(mktemp)"
      if ${pkgs.jq}/bin/jq --argjson sl '${builtins.toJSON statusLine}' \
          '.statusLine = $sl' "$settings" > "$tmp"; then
        cat "$tmp" > "$settings"   # keep the file's existing mode
      else
        echo "agy: could not merge statusLine into $settings" >&2
      fi
      rm -f "$tmp"
    fi
  '';
}

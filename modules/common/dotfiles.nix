# Dotfiles shared by macOS and Ubuntu.
{ lib, ... }:

{
  home.file = {
    ".config/nvim".source = ../../dotfiles/nvim;
    ".config/nix/nix.conf".source = ../../dotfiles/nix.conf;
    ".config/herdr/config.toml".source = ../../dotfiles/herdr/config.toml;
    ".config/herdr/plugins.txt".source = ../../dotfiles/herdr/plugins.txt;
    ".config/herdr-app/mods/skillshare".source = ../../dotfiles/herdr-app/mods/skillshare;
    ".config/herdr-app/layouts".source = ../../dotfiles/herdr-app/layouts;
    ".config/herdr/mods/skillshare".source = ../../dotfiles/herdr-app/mods/skillshare;
    ".config/herdr/layouts".source = ../../dotfiles/herdr-app/layouts;
  };

  home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    plugins_file="$HOME/.config/herdr/plugins.txt"
    if [ -f "$plugins_file" ] && command -v herdr >/dev/null 2>&1; then
      while IFS= read -r plugin || [ -n "$plugin" ]; do
        plugin="$(echo "$plugin" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        [ -z "$plugin" ] && continue
        case "$plugin" in \#*) continue ;; esac
        $DRY_RUN_CMD herdr plugin install "$plugin" --yes 2>/dev/null || true
      done < "$plugins_file"
    fi
  '';
}

{ config, ... }:

{
  home.sessionVariables = {
    hi_can = "Hi barbie";
    EDITOR = "nvim";
    HISTFILE = "${config.home.homeDirectory}/.prompt_history";
    HISTFILESIZE = "5000";
  };

  # Shell aliases for nix-darwin management
  home.shellAliases = {
    # Rebuild nix-darwin configuration
    nix-reb = "sudo darwin-rebuild switch --flake ~/nix#MacBook-Pro";

    # Open nix configuration in VSCode
    nix-open = "code ~/nix";
  };
}

{ hostVars, ... }:
{
  imports = [
    ./claude.nix
    ./git.nix
    ./dotfiles.nix
    ./shell.nix
    ./skills.nix
    ./tmux.nix
  ];

  home.username = hostVars.user;
  home.homeDirectory = hostVars.home;

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

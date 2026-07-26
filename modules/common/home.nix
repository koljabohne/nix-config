{ hostVars, ... }:
{
  imports = [
    ./git.nix
    ./dotfiles.nix
    ./shell.nix
    ./skills.nix
  ];

  home.username = hostVars.user;
  home.homeDirectory = hostVars.home;

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

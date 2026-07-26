{ hostVars, pkgs, ... }:
{
  imports = [
    ./programs/git.nix
    ./dotfiles.nix
    ./shell.nix
    ./skills.nix
  ];

  home.username = hostVars.user;
  home.homeDirectory = hostVars.home;

  home.packages = [
    pkgs.python312
    pkgs.uv
  ];

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

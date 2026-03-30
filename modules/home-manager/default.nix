{ config, pkgs, ... }:

let
  vars = import ../../vars.nix;
in
{
  imports = [
    ./programs/vscode.nix
    ./programs/git.nix
    ./programs/zsh.nix
    ./dotfiles.nix
    ./shell.nix
  ];

  home.username = vars.user;
  home.homeDirectory = vars.home;

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
    pkgs.python312
    pkgs.poetry
  ];

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

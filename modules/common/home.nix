{ hostVars, ... }:
{
  imports = [
    ./a2abridge.nix
    ./agy.nix
    ./claude.nix
    ./codex.nix
    ./git.nix
    ./kimi.nix
    ./dotfiles.nix
    ./shell.nix
    ./tmux.nix
  ];

  home.username = hostVars.user;
  home.homeDirectory = hostVars.home;

  home.sessionPath = [
    "${hostVars.home}/.local/bin"
  ];

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

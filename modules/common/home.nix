{ hostVars, ... }:
{
  imports = [
    ./a2abridge.nix
    ./agy.nix
    ./claude.nix
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

  home.file.".local/bin/agent-quota" = {
    source = ../../scripts/agent-quota;
    executable = true;
  };

  home.file.".local/bin/agent-session" = {
    source = ../../scripts/agent-session;
    executable = true;
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}

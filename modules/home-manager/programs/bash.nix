{ hostVars, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = builtins.readFile ../../../dotfiles/bashrc;

    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historyFile = "${hostVars.home}/.local/state/bash/history";
    historySize = 50000;
    historyFileSize = 50000;

    shellAliases = {
      vi = "nvim";
      nix-reb = "home-manager switch --flake ${hostVars.repoPath}#${hostVars.configurationName}";
      nix-open = "$EDITOR ${hostVars.repoPath}";
    };
  };
}

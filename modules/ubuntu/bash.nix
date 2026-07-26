# Bash is configured only for Ubuntu CLI hosts.
{ hostVars, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = builtins.readFile ../../dotfiles/bashrc;

    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historyFile = "${hostVars.home}/.local/state/bash/history";
    historySize = 50000;
    historyFileSize = 50000;

    shellAliases = {
      vi = "nvim";
      nix-reb = "home-manager switch --impure --flake ${hostVars.repoPath}#${hostVars.configurationName}";
      nix-pull = "git -C ${hostVars.repoPath} pull --ff-only";
      nix-deploy = "${hostVars.repoPath}/scripts/deploy-ubuntu.sh";
      nix-open = "$EDITOR ${hostVars.repoPath}";
    };
  };
}

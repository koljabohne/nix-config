# ZSH is the interactive shell for Ubuntu CLI hosts.
{ hostVars, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";

    autosuggestion = {
      enable = true;
      highlight = "fg=8";
      strategy = [ "history" ];
    };

    syntaxHighlighting.enable = true;

    history = {
      append = true;
      path = "${hostVars.home}/.local/state/zsh/history";
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
      ignoreSpace = true;
      share = false;
    };

    historySubstringSearch = {
      enable = true;
      searchUpKey = [
        "^[[A"
        "^P"
      ];
      searchDownKey = [
        "^[[B"
        "^N"
      ];
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
      ];
    };

    shellAliases = {
      vi = "nvim";
      ls = "ls --color=auto";
      nix-reb = "home-manager switch --impure --flake ${hostVars.repoPath}#${hostVars.configurationName}";
      nix-pull = "git -C ${hostVars.repoPath} pull --ff-only";
      nix-deploy = "${hostVars.repoPath}/scripts/deploy-ubuntu.sh";
      nix-open = "$EDITOR ${hostVars.repoPath}";
    };

    initContent = ''
      # Initialize fnm with automatic Node version switching.
      if command -v fnm >/dev/null 2>&1; then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi
    '';
  };
}

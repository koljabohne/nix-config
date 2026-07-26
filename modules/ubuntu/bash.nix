# Bash is configured only for Ubuntu CLI hosts.
{
  hostVars,
  inputs,
  pkgs,
  ...
}:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      # Load ble.sh without attaching yet, so the remaining Bash setup can
      # safely configure Readline, completions, and the prompt first.
      if [[ $- == *i* ]]; then
        source -- ${pkgs.blesh}/share/blesh/ble.sh --attach=none

        # Keep the Ubuntu Bash experience aligned with the macOS ZSH setup.
        export OSH=${inputs.oh-my-bash}
        OSH_THEME="robbyrussell"
        DISABLE_AUTO_UPDATE=true
        OMB_USE_SUDO=false
        completions=(
          git
          docker
          docker-compose
        )
        aliases=()
        plugins=(
          git
        )
        source "$OSH/oh-my-bash.sh"
      fi

      ${builtins.readFile ../../dotfiles/bashrc}

      # Attach only after all other interactive Bash configuration is loaded.
      [[ ! ''${BLE_VERSION-} ]] || ble-attach
    '';

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

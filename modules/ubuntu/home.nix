{ hostVars, lib, ... }:

{
  imports = [
    ../common/home.nix
    ./packages.nix
    ./zsh.nix
  ];

  # Ensure Herdr CLI and Herdr Core (hc) are installed for remote management
  home.activation.herdrCore = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! command -v herdr >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/herdr" ]; then
      $DRY_RUN_CMD curl -fsSL https://herdr.dev/install.sh | sh 2>/dev/null || true
    fi
    if ! command -v hc >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/hc" ]; then
      $DRY_RUN_CMD curl -fsSL https://releases.herdr.dev/core/install.sh | sh 2>/dev/null || true
    fi
  '';

  home.sessionVariables = {
    NIX_CONFIG_BRANCH = hostVars.branch;
    NIX_CONFIG_FLAKE = hostVars.configurationName;
    NIX_SYSTEM = hostVars.system;
  };
}

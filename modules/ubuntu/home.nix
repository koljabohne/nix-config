{ hostVars, ... }:

{
  imports = [
    ../common/home.nix
    ./packages.nix
    ./bash.nix
  ];

  home.sessionVariables = {
    NIX_CONFIG_BRANCH = hostVars.branch;
    NIX_CONFIG_FLAKE = hostVars.configurationName;
    NIX_SYSTEM = hostVars.system;
  };
}

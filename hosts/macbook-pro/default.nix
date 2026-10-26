{ pkgs, config, lib, hostVars, ... }:
{
  imports = [
    ../../modules/macos/system/packages.nix
    ../../modules/macos/system/homebrew.nix
    ../../modules/macos/system/fonts.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  system.primaryUser = hostVars.user;

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;

  # Used for backwards compatibility
  system.stateVersion = 5;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = hostVars.system;

  # Disable app linking warning
  system.activationScripts.applications.text = lib.mkForce "";

  # Enable Touch ID for sudo (including inside tmux/screen)
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };
}

{ pkgs, config, lib, ... }:

let
  vars = import ./vars.nix;
in
{
  imports = [
    ../../modules/macos/system/packages.nix
    ../../modules/macos/system/homebrew.nix
    ../../modules/macos/system/fonts.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Necessary for using flakes on this system
  nix.settings.experimental-features = "nix-command flakes";

  system.primaryUser = vars.user;

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;

  # Used for backwards compatibility
  system.stateVersion = 5;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = vars.system;

  # Disable app linking warning
  system.activationScripts.applications.text = lib.mkForce "";
}

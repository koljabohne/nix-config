# Packages installed at the macOS system level.
{ pkgs, ... }:

let
  commonPackages = import ../../common/packages.nix { inherit pkgs; };
in
{
  environment.systemPackages = commonPackages ++ (with pkgs; [
    # Development
    jre_headless

    # Media
    ffmpeg
    scdl

    # System
    macpm
    cocoapods
    smbclient-ng
    oh-my-zsh
    pympress
  ]);

  # Reference omz in zshrc
  environment.etc."zsh/omz-script".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh/";
}

{ pkgs, ... }:

{
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
    pkgs.merriweather
  ];
}

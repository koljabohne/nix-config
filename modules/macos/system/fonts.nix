# macOS system fonts.
{ pkgs, ... }:

{
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
    pkgs.merriweather
    pkgs.source-serif-pro
    pkgs.inter
  ];
}

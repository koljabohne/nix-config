{ pkgs, ... }:

{
  imports = [
    ../default.nix
    ../programs/vscode.nix
    ../programs/zsh.nix
  ];

  home.file.".zshrc".source = ../../../dotfiles/zshrc;

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
  ];

  home.shellAliases = {
    nix-reb = "sudo darwin-rebuild switch --flake ~/nix#MacBook-Pro";
    nix-open = "code ~/nix";
  };
}

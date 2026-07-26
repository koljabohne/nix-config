{ pkgs, ... }:

{
  imports = [
    ../common/home.nix
    ./git.nix
    ./vscode.nix
    ./zsh.nix
  ];

  home.file.".zshrc".source = ../../dotfiles/zshrc;

  home.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
    pkgs.python312
    pkgs.poetry
    pkgs.uv
  ];

  home.shellAliases = {
    nix-reb = "sudo darwin-rebuild switch --flake ~/nix#MacBook-Pro";
    nix-open = "code ~/nix";
  };
}

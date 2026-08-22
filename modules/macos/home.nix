{ pkgs, ... }:

{
  imports = [
    ../common/home.nix
    ../common/latex-docker.nix
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
    nix-reb = "sudo env NIX_CONFIG_REPO=\"$HOME/nix\" darwin-rebuild switch --impure --flake \"$HOME/nix#MacBook-Pro\"";
    nix-open = "code ~/nix";
  };
}

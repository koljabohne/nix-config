{ pkgs, ... }:

{
  imports = [
    ../common/home.nix
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
    nix-reb = "sudo env NIX_CONFIG_REPO=\"$NIX_CONFIG_REPO\" darwin-rebuild switch --impure --flake \"$NIX_CONFIG_REPO#MacBook-Pro\"";
    nix-open = "code ~/nix";
  };
}

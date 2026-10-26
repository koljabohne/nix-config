{ pkgs, ... }:

{
  imports = [
    ../common/home.nix
    ../common/latex-docker.nix
    ./vscode.nix
    ./zsh.nix
  ];

  home.file.".zshrc".source = ../../dotfiles/zshrc;
  home.file."Library/Application Support/com.mitchellh.ghostty/config".source = ../../dotfiles/ghostty/config;

  home.file.".condarc".text = ''
    channels:
      - conda-forge
      - defaults
    auto_activate_base: true
  '';

  home.file.".config/uv/uv.toml".text = ''
    # Global Astral uv configuration
    # Reference: https://docs.astral.sh/uv/reference/settings/
  '';

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
    nix-update = "nix flake update --flake \"$HOME/nix\" && nix-reb";
    nix-update-vscode = "nix flake update --flake \"$HOME/nix\" nixpkgs nix-vscode-extensions && nix-reb";
  };
}

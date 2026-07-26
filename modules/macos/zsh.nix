# Zsh is configured only for macOS.
{ ... }:

{
  # Disable home-manager's zsh management since we use a custom .zshrc
  programs.zsh.enable = false;
}

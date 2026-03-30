{ ... }:

{
  home.file = {
    ".config/nvim".source = ../../dotfiles/nvim;
    ".zshrc".source = ../../dotfiles/zshrc;
    ".config/nix/nix.conf".source = ../../dotfiles/nix.conf;
  };
}

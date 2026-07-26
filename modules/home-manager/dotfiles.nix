{ ... }:

{
  home.file = {
    ".config/nvim".source = ../../dotfiles/nvim;
    ".config/nix/nix.conf".source = ../../dotfiles/nix.conf;
  };
}

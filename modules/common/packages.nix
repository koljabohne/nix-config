{ pkgs }:

with pkgs;
[
  # Editors and terminal tools
  vim
  neovim
  wget
  tree
  htop
  tmux
  nmap
  fzf

  # Development
  fnm
  nodejs_20
  pnpm_9
  go

  # Network and security
  wireguard-tools
  openvpn
  sops
  gnupg
  age

  # Document tooling
  ocamlPackages.cpdf
]

{ pkgs }:

with pkgs;
[
  # Editors and terminal tools
  vim
  neovim
  wget
  tree
  htop
  nmap
  fzf
  dust
  jq

  # Development
  gh
  tea
  fnm
  nodejs_22
  pnpm
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

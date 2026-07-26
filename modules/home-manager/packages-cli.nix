{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
    jre_headless

    # Network and security
    wireguard-tools
    openvpn
    sops
    gnupg
    age

    # Media and document tooling
    ffmpeg
    scdl
    ocamlPackages.cpdf
  ];
}

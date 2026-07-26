{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim

    # CLI Tools
    wget
    tree
    htop
    tmux
    nmap
    fzf

    # Development
    fnm # node version manager
    nodejs_20
    pnpm_9
    go

    # Network & Security
    wireguard-tools
    openvpn
    sops
    gnupg
    age

    # System
    macpm
    cocoapods
    smbclient-ng
    oh-my-zsh
    pympress
    ocamlPackages.cpdf
  ];

  # Reference omz in zshrc
  environment.etc."zsh/omz-script".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh/";
}

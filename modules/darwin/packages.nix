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
    go

    # Network & Security
    wireguard-tools
    openvpn
    sops
    gnupg
    age

    # Media
    ffmpeg
    scdl # soundcloud downloader

    # System
    gemini-cli
    macpm
    cocoapods
    smbclient-ng
    oh-my-zsh
  ];

  # Reference omz in zshrc
  environment.etc."zsh/omz-script".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh/";
}

{ config, pkgs, ... }:

let 
    vars = import ./vars.nix;
in
{
    home.username = vars.user;
    home.homeDirectory = vars.home;

    home.file = {
        ".config/nvim".source = dotfiles/nvim;
        ".zshrc".source = dotfiles/zshrc;
        ".config/nix/nix.conf".source = dotfiles/nix.conf;
    };

    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
}
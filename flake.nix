{
  description = "Kolja's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # homebrew package manager
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-fvm = {
      url = "github:leoafarias/homebrew-fvm";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    # vscode ext
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-fvm, home-manager, nix-vscode-extensions}:
  let
    vars = import ./vars.nix;

    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;
      # security.pam.enableSudoTouchIdAuth = true;
      
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      
      system.primaryUser = vars.user;


      environment.systemPackages = with pkgs; [ 
          vim
          wget
          wireguard-tools
      	  neovim
          tmux
          tree
          htop
          fnm # node version manager
          go
          scdl # https://github.com/scdl-org/scdl soundcloud
          asitop
          cocoapods
          ffmpeg
          nmap
	        openvpn
	        oh-my-zsh
          fzf
          nodejs_20
          sops
          gnupg
          age
          smbclient-ng
          #texliveFull

  #           (texlive.combine {
  #   inherit (texlive) 
  #   scheme-medium
  #   latex
  #   dvipng
  #         collection-latex
  #     collection-latexrecommended
  #     collection-fontsrecommended
  #         amsmath
  #     amsfonts;
  # })
        ];


      homebrew = {
        enable = true;
        brews = [
          "mas"
          "gnu-sed"
          "poppler"
          "nvm"
          "cmake"
          "fvm"
          "youtubedr"
          "yt-dlp"
          "dua-cli"
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
        ];
      casks = [
          "firefox"
          "onyx"
          "opera"
          "xquartz"
          "disk-expert"
          "aldente"
          "dozer"
          "chromedriver"
          "MonitorControl"
          #"ghostty"
          "obsidian"
          "keyclu"
          "anki"
          "betterdisplay"
          "cyberduck"
          "alt-tab"
          "miniconda"
          "zen-browser"
          "deepl"
          "iterm2"
          "docker-desktop"
	        "docker-toolbox"
        ];
        masApps = {
          #"Xcode" = 497799835;
          # "Magnet" = 441258766;
        };
        onActivation.cleanup = "zap";
      };

      # ref omz in zshrc
      environment.etc."zsh/omz-script".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh/";

      # ref nvm
      # environment.etc."nvm".source = "${pkgs.fnm}";


      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.geist-mono
        pkgs.merriweather
        
      ];

      # Auto upgrade nix package and the daemon service.
      # services.nix-daemon.enable = true;
      
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacBook-Pro
    darwinConfigurations."MacBook-Pro" = nix-darwin.lib.darwinSystem {
system = "aarch64-darwin";
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = vars.user;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "leoafarias/homebrew-fvm" = homebrew-fvm;
            };
          };
        }

        home-manager.darwinModules.home-manager
        {
          # 1. Overlay für VS Code Extensions aktivieren
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default
          ];
          
          # 2. WICHTIG: Hier fehlte das Semikolon am Ende!
          nixpkgs.config.allowUnfree = true;

          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            useUserPackages = true;
            
            # Hier nutzen wir besser die Variable statt den Namen hart zu codieren
            users.${vars.user} = import ./home.nix;
          };
          
          # Das ist okay, definiert wo dein User-Home liegt
          users.users.${vars.user}.home = vars.home;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Pro".pkgs;
  };
}

{
  description = "Kolja's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, home-manager}:
  let
    vars = import ./vars.nix;

    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;
      security.pam.enableSudoTouchIdAuth = true;
      
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";


      environment.systemPackages =
        [ 
          pkgs.vim
      	  pkgs.neovim
          pkgs.tmux
          pkgs.asitop
          pkgs.cocoapods
	        pkgs.openvpn
	        pkgs.oh-my-zsh
          pkgs.fzf
        ];

      # ref omz in zshrc
      environment.etc."zsh/omz-script".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh/";


      homebrew = {
        enable = true;
        brews = [
          "mas"
          "cmake"
          "zsh-autosuggestions"
          "zsh-syntax-highlighting"
        ];
        casks = [
          "firefox"
          "aldente"
          "obsidian"
          "cyberduck"
          "alt-tab"
          "miniconda"
          "zen-browser"
          "mactex"
          "miktex-console"
          #"visual-studio-code"
          "iterm2"
          "docker"
	        "docker-toolbox"
          #"spotify"
          #"docker-compose"
        ];
        masApps = {
          #"Xcode" = 497799835;
          "Magnet" = 441258766;
        };
        #onActivation.cleanup = "zap";
      };

      fonts.packages = 
        [
         ( pkgs.nerdfonts.override { fonts = ["JetBrainsMono" "GeistMono"]; })
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      
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
      modules = 
      [ 
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
            };
          };
        }

        home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.local-user = import ./home.nix;
            };
            users.users.local-user.home = vars.home;
          }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Pro".pkgs;
  };
}
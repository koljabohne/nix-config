{
  description = "Kolja's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, homebrew-fvm, home-manager, nix-vscode-extensions }:
  let
    vars = import ./vars.nix;
  in
  {
    darwinConfigurations."MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        # Host configuration
        ./hosts/macbook-pro/default.nix

        # Homebrew integration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            autoMigrate = true;
            enableRosetta = false;
            user = vars.user;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "leoafarias/homebrew-fvm" = homebrew-fvm;
            };
          };
        }

        # Home Manager integration
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default
          ];

          nixpkgs.config.allowUnfree = true;

          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${vars.user} = import ./modules/home-manager;
          };

          users.users.${vars.user}.home = vars.home;
        }
      ];
    };

    # Expose the package set for convenience
    darwinPackages = self.darwinConfigurations."MacBook-Pro".pkgs;
  };
}

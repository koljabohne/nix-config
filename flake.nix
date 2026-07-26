{
  description = "macOS and Linux home configuration";

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

    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-fvm,
      home-manager,
      nix-vscode-extensions,
      ...
    }:
    let
      configuredRepoPath = builtins.getEnv "NIX_CONFIG_REPO";
      environmentHome = builtins.getEnv "HOME";
      defaultRepoPath =
        if environmentHome == "" then
          throw "Set NIX_CONFIG_REPO and evaluate with --impure"
        else
          "${environmentHome}/nix";
      repoPath =
        if configuredRepoPath == "" then
          defaultRepoPath
        else
          configuredRepoPath;
      loadLocalConfig =
        path:
        let
          configPath = builtins.toPath "${path}/config.local.toml";
        in
        if builtins.pathExists configPath then
          builtins.fromTOML (builtins.readFile configPath)
        else
          { };
      macbookLocalConfig = loadLocalConfig repoPath;
      macbookVars = import ./hosts/macbook-pro/vars.nix {
        localConfig = macbookLocalConfig;
        inherit repoPath;
      };
      ubuntuVars = import ./hosts/ubuntu-cli/vars.nix;
      ubuntuLocalConfig = loadLocalConfig ubuntuVars.repoPath;
    in
    {
      darwinConfigurations.${macbookVars.configurationName} = nix-darwin.lib.darwinSystem {
        system = macbookVars.system;
        specialArgs = {
          hostVars = macbookVars;
        };
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
              user = macbookVars.user;
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
              extraSpecialArgs = {
                inherit inputs;
                hostVars = macbookVars;
                localConfig = macbookLocalConfig;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${macbookVars.user} = import ./hosts/macbook-pro/home.nix;
            };

            users.users.${macbookVars.user}.home = macbookVars.home;
          }
        ];
      };

      homeConfigurations.${ubuntuVars.configurationName} =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = ubuntuVars.system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
            hostVars = ubuntuVars;
            localConfig = ubuntuLocalConfig;
          };
          modules = [
            ./hosts/ubuntu-cli/default.nix
          ];
        };

      # Expose the package set for convenience
      darwinPackages = self.darwinConfigurations.${macbookVars.configurationName}.pkgs;
    };
}

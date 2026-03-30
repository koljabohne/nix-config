# Nix-Darwin Configuration

A modular nix-darwin configuration with home-manager integration for macOS system management.

## Project Structure

```
/Users/local-user/nix/
├── flake.nix                    # Main flake entry point
├── vars.nix                     # User variables (username, home path)
├── hosts/
│   └── macbook-pro/
│       └── default.nix          # Host-specific configuration
├── modules/
│   ├── darwin/
│   │   ├── packages.nix         # System packages (nixpkgs)
│   │   ├── homebrew.nix         # Homebrew brews, casks, and mas apps
│   │   └── fonts.nix            # System fonts
│   └── home-manager/
│       ├── default.nix          # Home-manager entry point
│       ├── programs/
│       │   ├── vscode.nix       # VSCode configuration & extensions
│       │   └── git.nix          # Git configuration
│       ├── shell.nix            # Shell aliases & environment variables
│       └── dotfiles.nix         # Dotfile management
└── dotfiles/
    ├── nvim/                    # Neovim configuration
    ├── zshrc                    # Zsh configuration
    └── nix.conf                 # Nix configuration

```

## Initial Setup

1. Install Nix:
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. Clone this repository:
   ```bash
   git clone <your-repo> ~/nix
   cd ~/nix
   ```

3. Update `vars.nix` with your username and home path if needed

4. Install nix-darwin:
   ```bash
   nix run nix-darwin --experimental-features 'nix-command flakes' -- switch --flake ~/nix#MacBook-Pro
   ```

## Daily Usage

### Quick Commands (Shell Aliases)

After the first rebuild, you can use these convenient aliases:

- `dr` - Rebuild and switch to new configuration
- `nc` - Open nix config directory in VSCode
- `ne` - Open flake.nix in VSCode

### Manual Rebuild

If you prefer the full command:

```bash
sudo darwin-rebuild switch --flake ~/nix#MacBook-Pro
```

Or from anywhere:

```bash
cd ~/nix && sudo darwin-rebuild switch --flake .#MacBook-Pro
```

### Update Flake Inputs

Update all flake inputs to their latest versions:

```bash
cd ~/nix
nix flake update
```

## Adding Packages

### System Packages (Nixpkgs)

Edit `modules/darwin/packages.nix`:

```nix
environment.systemPackages = with pkgs; [
  vim
  wget
  # Add your package here
  ripgrep
];
```

### User Packages (Home Manager)

Edit `modules/home-manager/default.nix`:

```nix
home.packages = [
  pkgs.python312
  # Add your package here
  pkgs.bat
];
```

### Homebrew Packages

Edit `modules/darwin/homebrew.nix`:

```nix
brews = [
  "mas"
  # Add brew formula here
];

casks = [
  "firefox"
  # Add cask here
];

masApps = {
  "Xcode" = 497799835;
  # Add Mac App Store apps here
};
```

After editing any configuration file, run `dr` or the rebuild command.

## Configuration Modules

### System Configuration

- **packages.nix** - CLI tools, development tools, system utilities
- **homebrew.nix** - Homebrew formulas, casks, and Mac App Store apps
- **fonts.nix** - System fonts (Nerd Fonts, etc.)

### User Configuration (Home Manager)

- **programs/vscode.nix** - VSCode settings, keybindings, and extensions
- **programs/git.nix** - Git user config, aliases, and global ignores
- **shell.nix** - Shell aliases and environment variables
- **dotfiles.nix** - Manages dotfiles (nvim, zshrc, etc.)

## Tips

- All configuration is declarative and version-controlled
- Changes require a rebuild to take effect
- Nix packages are isolated and don't conflict with system packages
- You can search for packages at https://search.nixos.org/packages
- Use `nix-shell -p <package>` to try packages temporarily

## Troubleshooting

### Git tree is dirty warning

This is normal when you have uncommitted changes. The configuration will still build.

### File conflicts during activation

If home-manager reports file conflicts, you can either:
- Back up and remove the existing file
- Add `force = true` to the relevant configuration option

### Permission issues

Most darwin-rebuild commands require sudo for system-level changes.

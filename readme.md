# Nix configuration for macOS and Ubuntu

This flake manages two kinds of hosts:

- macOS through nix-darwin with Home Manager
- Ubuntu and other non-NixOS Linux systems through standalone Home Manager

Ubuntu remains an Ubuntu system. APT continues to manage the operating system,
drivers, and system services. Nix and Home Manager manage the user-level CLI
tools, shell configuration, Git, Neovim, and agent skills.

## Project structure

```text
.
├── flake.nix
├── hosts/
│   ├── macbook-pro/
│   │   ├── default.nix
│   │   ├── home.nix
│   │   └── vars.nix
│   └── ubuntu-cli/
│       ├── default.nix
│       └── vars.nix
├── modules/
│   ├── common/
│   │   ├── home.nix
│   │   ├── packages.nix
│   │   ├── dotfiles.nix
│   │   ├── git.nix
│   │   ├── shell.nix
│   │   └── skills.nix
│   ├── macos/
│   │   ├── home.nix
│   │   ├── vscode.nix
│   │   ├── zsh.nix
│   │   └── system/
│   │       ├── fonts.nix
│   │       ├── homebrew.nix
│   │       └── packages.nix
│   └── ubuntu/
│       ├── home.nix
│       ├── bash.nix
│       └── packages.nix
├── dotfiles/
│   ├── bashrc
│   ├── zshrc
│   └── nvim/
└── skills/
```

Host-specific defaults such as architecture live in the corresponding
`hosts/<host>/vars.nix`. macOS reads its private username and home directory
from `config.local.toml`. Ubuntu reads `USER` and `HOME` from the target user's
environment.

`modules/common/packages.nix` is the shared CLI package list. macOS installs
that list system-wide and appends its full desktop and development package set
in `modules/macos/system/packages.nix`; its Home Manager profile includes both
Poetry and `uv`. Ubuntu installs the shared list plus its lean Python and `uv`
environment through `modules/ubuntu/packages.nix`.

## Private local configuration

Each checkout has exactly one private configuration file in the repository
root:

```text
config.local.toml
```

The file is ignored by Git. It contains scoped TOML configuration:

```toml
[macos]
username = "your-local-user"
home = "/Users/your-local-user"

[git]
username = "Your Name"
email = "you@example.com"
```

Additional scopes can be added to the same file later. The `macos` scope holds
machine-local account data, while the `git` scope configures Git directly.
Because the file is local and ignored, all rebuilds that use it must be
evaluated with `--impure`.

## macOS

The existing Mac configuration is available as `MacBook-Pro`.

Initial activation:

```bash
nix run nix-darwin -- switch --impure --flake ~/nix#MacBook-Pro
```

Subsequent rebuilds:

```bash
sudo darwin-rebuild switch --impure --flake ~/nix#MacBook-Pro
```

The `nix-reb` alias runs the same rebuild command.

## Ubuntu CLI

### Automatic deployment

On a fresh Ubuntu server, run the deployment script as the account that should
receive the Home Manager environment:

```bash
curl --fail --location \
  https://raw.githubusercontent.com/PracticalPassion/dotfiles/main/scripts/deploy-ubuntu.sh \
  | bash
```

The script:

- installs the required Ubuntu packages
- installs Nix in multi-user mode when necessary
- clones the repository to `$HOME/nix`, or updates an existing clean clone
- detects `x86_64-linux` or `aarch64-linux`
- activates the `ubuntu-cli` Home Manager configuration

The raw GitHub URL requires a public repository. For a private repository,
transfer the script to the server through an authenticated channel first and
run it locally. The clone URL, deployment branch, and clone location can be
overridden:

```bash
export NIX_REPO_URL=git@github.com:PracticalPassion/dotfiles.git
export NIX_CONFIG_BRANCH=main
export NIX_CONFIG_REPO=/srv/nix-config

curl --fail --location \
  https://raw.githubusercontent.com/PracticalPassion/dotfiles/main/scripts/deploy-ubuntu.sh \
  | bash
```

The SSH clone URL requires a configured SSH key on the server.

After activation, the Ubuntu Bash environment provides:

```text
nix-reb      Apply the checked-out configuration
nix-pull     Fast-forward the current repository branch
nix-deploy   Pull the configured deployment branch and apply it
nix-open     Open the repository in $EDITOR
```

### Manual deployment

#### 1. Review the host variables

`hosts/ubuntu-cli/vars.nix` reads the target account automatically:

```nix
let
  user = requireEnv "USER";
  home = requireEnv "HOME";
in
{
  inherit user home;

  system = "x86_64-linux";
  configurationName = "ubuntu-cli";
  repoPath = "${home}/nix";
}
```

The deployment script sets `NIX_SYSTEM` automatically. For a manual deployment
on ARM, export `NIX_SYSTEM=aarch64-linux` first. Set `NIX_CONFIG_REPO` before
running Home Manager if the repository is not cloned to `$HOME/nix`.

Run the activation as the target account, not through `sudo`, so `USER` and
`HOME` refer to the account that Home Manager should configure.

#### 2. Install Nix

On a normal Ubuntu system with systemd, install Nix in multi-user mode:

```bash
sudo apt update
sudo apt install -y curl git xz-utils
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

Start a new login shell after the installer completes.

#### 3. Clone this repository

The clone location must match `repoPath` in `hosts/ubuntu-cli/vars.nix`:

```bash
git clone <repository-url> ~/nix
cd ~/nix
```

#### 4. Activate Home Manager

The first activation can use Home Manager directly from its flake:

```bash
nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/home-manager -- \
  switch --impure -b hm-backup --flake ~/nix#ubuntu-cli
```

The backup suffix prevents existing files such as `~/.bashrc` from being
silently overwritten. The explicit feature flag is only needed during
bootstrap; the managed `~/.config/nix/nix.conf` enables flakes afterwards.
Home Manager itself is also part of the activated profile:

```bash
home-manager switch --impure --flake ~/nix#ubuntu-cli
```

The `nix-reb` Bash alias runs this command using the values from the Ubuntu
vars file.

## What the Ubuntu profile installs

The Linux CLI profile includes:

- Bash with completion, aliases, persistent history, and `dotfiles/bashrc`
- Git and the global ignore file
- Neovim and the repository's Neovim configuration
- Python with `uv` for project and dependency management
- common terminal and development tools
- the selected external and local agent skills

External skills are pinned by `flake.lock`. Local skills are linked from
`repoPath/skills`, so edits in this repository are visible immediately.

Home Manager generates `~/.bashrc` and inserts the contents of
`dotfiles/bashrc` into it. The macOS-only `dotfiles/zshrc` is imported solely
by the Darwin profile and is never installed by the Ubuntu profile.

## History and synchronization

Home Manager configures Bash to store history at:

```text
~/.local/state/bash/history
```

The history file is mutable state and is deliberately not added to the Nix
store or Git. The Mac continues to use its separate Zsh history at
`~/.zsh_history`.

To share history between machines, synchronize the relevant history file with
a state synchronization tool such as Syncthing. Do not commit shell history to
the repository because it can contain sensitive commands, paths, hostnames, or
tokens.

Codex history is also mutable state, normally stored in
`~/.codex/history.jsonl`. It is not managed by this flake. Avoid synchronizing
the complete `~/.codex` directory: it can contain authentication data,
machine-local databases, active SQLite files, and other device-specific state.

## Updating

Update all pinned inputs:

```bash
cd ~/nix
nix flake update
```

Then activate the appropriate configuration:

```bash
# macOS
sudo darwin-rebuild switch --impure --flake ~/nix#MacBook-Pro

# Ubuntu
home-manager switch --impure --flake ~/nix#ubuntu-cli
```

## Adding packages

Packages shared by macOS and Ubuntu belong in:

```text
modules/common/packages.nix
```

Ubuntu-only CLI packages belong in:

```text
modules/ubuntu/packages.nix
```

macOS system packages belong in:

```text
modules/macos/system/packages.nix
```

Homebrew formulae and applications belong in:

```text
modules/macos/system/homebrew.nix
```

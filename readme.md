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
│   ├── darwin/
│   └── home-manager/
│       ├── default.nix
│       ├── packages-cli.nix
│       ├── profiles/
│       │   ├── darwin.nix
│       │   └── linux-cli.nix
│       └── programs/
│           ├── bash.nix
│           ├── git.nix
│           ├── vscode.nix
│           └── zsh.nix
├── dotfiles/
│   ├── bashrc
│   ├── zshrc
│   └── nvim/
└── skills/
```

Host-specific values such as username, home directory, architecture, and
repository path live in the corresponding `hosts/<host>/vars.nix`.

## macOS

The existing Mac configuration is available as `MacBook-Pro`.

Initial activation:

```bash
nix run nix-darwin -- switch --flake ~/nix#MacBook-Pro
```

Subsequent rebuilds:

```bash
sudo darwin-rebuild switch --flake ~/nix#MacBook-Pro
```

The `nix-reb` alias runs the same rebuild command.

## Ubuntu CLI

### 1. Adjust the host variables

Edit `hosts/ubuntu-cli/vars.nix` before activating the configuration:

```nix
let
  user = "kolja";
  home = "/home/${user}";
in
{
  inherit user home;

  system = "x86_64-linux";
  configurationName = "${user}@ubuntu";
  repoPath = "${home}/nix";
}
```

Use `aarch64-linux` instead of `x86_64-linux` on an ARM Linux host.

### 2. Install Nix

On a normal Ubuntu system with systemd, install Nix in multi-user mode:

```bash
sudo apt update
sudo apt install -y curl git xz-utils
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

Start a new login shell after the installer completes.

### 3. Clone this repository

The clone location must match `repoPath` in `hosts/ubuntu-cli/vars.nix`:

```bash
git clone <repository-url> ~/nix
cd ~/nix
```

### 4. Activate Home Manager

The first activation can use Home Manager directly from its flake:

```bash
nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/home-manager -- \
  switch -b hm-backup --flake ~/nix#kolja@ubuntu
```

The backup suffix prevents existing files such as `~/.bashrc` from being
silently overwritten. The explicit feature flag is only needed during
bootstrap; the managed `~/.config/nix/nix.conf` enables flakes afterwards.
Home Manager itself is also part of the activated profile:

```bash
home-manager switch --flake ~/nix#kolja@ubuntu
```

The `nix-reb` Bash alias runs this command using the values from the Ubuntu
vars file.

## What the Ubuntu profile installs

The Linux CLI profile includes:

- Bash with completion, aliases, persistent history, and `dotfiles/bashrc`
- Git and the global ignore file
- Neovim and the repository's Neovim configuration
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
sudo darwin-rebuild switch --flake ~/nix#MacBook-Pro

# Ubuntu
home-manager switch --flake ~/nix#kolja@ubuntu
```

## Adding packages

Portable Ubuntu CLI packages belong in:

```text
modules/home-manager/packages-cli.nix
```

macOS system packages belong in:

```text
modules/darwin/packages.nix
```

Homebrew formulae and applications belong in:

```text
modules/darwin/homebrew.nix
```

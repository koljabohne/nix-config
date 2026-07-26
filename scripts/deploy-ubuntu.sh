#!/usr/bin/env bash

set -euo pipefail

repo_url="${NIX_REPO_URL:-https://github.com/PracticalPassion/dotfiles.git}"
repo_path="${NIX_CONFIG_REPO:-${HOME}/nix}"
repo_branch="${NIX_CONFIG_BRANCH:-main}"
flake_config="${NIX_CONFIG_FLAKE:-ubuntu-cli}"

log() {
  printf '==> %s\n' "$*"
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    fail "sudo is required to install Ubuntu prerequisites"
  fi
}

detect_nix_system() {
  case "$(uname -m)" in
    x86_64)
      printf '%s\n' "x86_64-linux"
      ;;
    aarch64 | arm64)
      printf '%s\n' "aarch64-linux"
      ;;
    *)
      fail "unsupported architecture: $(uname -m)"
      ;;
  esac
}

load_nix_environment() {
  local profile

  for profile in \
    "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" \
    "${HOME}/.nix-profile/etc/profile.d/nix.sh"; do
    if [ -f "$profile" ]; then
      set +u
      # shellcheck disable=SC1090
      . "$profile"
      set -u
      return
    fi
  done
}

install_prerequisites() {
  local command_name
  local missing_prerequisite=false

  if ! [ -r /etc/os-release ]; then
    fail "this deployment script supports Ubuntu only"
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  if [ "${ID:-}" != "ubuntu" ]; then
    fail "this deployment script supports Ubuntu only; detected ${ID:-unknown}"
  fi

  for command_name in curl git xz; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      missing_prerequisite=true
    fi
  done

  if [ "$missing_prerequisite" = false ] && [ -r /etc/ssl/certs/ca-certificates.crt ]; then
    return
  fi

  log "Installing Ubuntu prerequisites"
  run_as_root apt-get update
  run_as_root apt-get install -y ca-certificates curl git xz-utils
}

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    return
  fi

  log "Installing Nix in multi-user mode"
  curl --fail --location https://nixos.org/nix/install | sh -s -- --daemon
  load_nix_environment

  command -v nix >/dev/null 2>&1 || fail "Nix was installed but is not available in PATH"
}

update_repository() {
  if [ -d "${repo_path}/.git" ]; then
    if [ -n "$(git -C "$repo_path" status --porcelain)" ]; then
      fail "repository has local changes: ${repo_path}"
    fi

    log "Updating ${repo_path} from origin/${repo_branch}"
    git -C "$repo_path" fetch origin "$repo_branch"

    if git -C "$repo_path" show-ref --verify --quiet "refs/heads/${repo_branch}"; then
      git -C "$repo_path" switch "$repo_branch"
    else
      git -C "$repo_path" switch --create "$repo_branch" --track "origin/${repo_branch}"
    fi

    git -C "$repo_path" pull --ff-only origin "$repo_branch"
    return
  fi

  if [ -e "$repo_path" ] && [ -n "$(find "$repo_path" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
    fail "target exists and is not an empty Git repository: ${repo_path}"
  fi

  log "Cloning ${repo_url} to ${repo_path}"
  git clone --branch "$repo_branch" "$repo_url" "$repo_path"
}

prepare_local_config() {
  local config_file="${repo_path}/config.local.toml"

  if [ ! -e "$config_file" ]; then
    log "Creating private local configuration"
    (
      umask 077
      printf '[git]\\nusername = \"\"\\nemail = \"\"\\n' > "$config_file"
    )
  fi
}

activate_home_manager() {
  export USER="${USER:-$(id -un)}"
  export NIX_CONFIG_REPO="$repo_path"
  export NIX_CONFIG_BRANCH="$repo_branch"
  export NIX_CONFIG_FLAKE="$flake_config"
  export NIX_REPO_URL="$repo_url"
  export NIX_SYSTEM="${NIX_SYSTEM:-$(detect_nix_system)}"

  log "Activating ${flake_config} for ${USER} on ${NIX_SYSTEM}"
  nix --extra-experimental-features "nix-command flakes" \
    run github:nix-community/home-manager -- \
    switch --impure -b hm-backup --flake "${repo_path}#${flake_config}"
}

main() {
  install_prerequisites
  update_repository
  prepare_local_config
  install_nix
  activate_home_manager
  log "Ubuntu CLI environment is ready. Start a new login shell."
}

main "$@"

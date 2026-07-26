#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
default_repo_path="$(cd -- "${script_dir}/.." && pwd -P)"
repo_path="${NIX_CONFIG_REPO:-${default_repo_path}}"
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

  if [ ! -x /usr/bin/zsh ]; then
    missing_prerequisite=true
  fi

  if [ "$missing_prerequisite" = false ] && [ -r /etc/ssl/certs/ca-certificates.crt ]; then
    return
  fi

  log "Installing Ubuntu prerequisites"
  run_as_root apt-get update
  run_as_root apt-get install -y ca-certificates curl git xz-utils zsh
}

install_nix() {
  # A previous installer run may have completed without updating this active
  # shell. Load its profile before deciding that Nix must be installed again.
  load_nix_environment

  if command -v nix >/dev/null 2>&1; then
    return
  fi

  prepare_nix_installer_shell_backup

  log "Installing Nix in multi-user mode"
  curl --fail --location https://nixos.org/nix/install | sh -s -- --daemon
  load_nix_environment

  command -v nix >/dev/null 2>&1 || fail "Nix was installed but is not available in PATH"
}

prepare_nix_installer_shell_backup() {
  local bashrc="${NIX_INSTALLER_BASHRC:-/etc/bash.bashrc}"
  local installer_backup="${NIX_INSTALLER_BASHRC_BACKUP:-/etc/bash.bashrc.backup-before-nix}"
  local recovery_root="${NIX_INSTALLER_BACKUP_ROOT:-/var/backups/nix-installer-preflight}"
  local recovery_dir

  if [ ! -e "$installer_backup" ]; then
    return
  fi

  [ -f "$bashrc" ] || fail "expected shell profile does not exist: ${bashrc}"
  [ -f "$installer_backup" ] || fail "Nix installer backup is not a regular file: ${installer_backup}"

  recovery_dir="${recovery_root}/$(date -u +%Y%m%dT%H%M%SZ)-$$"
  log "Preserving existing Nix installer shell backups in ${recovery_dir}"
  run_as_root install -d -m 0700 "$recovery_dir"
  run_as_root cp -a -- "$bashrc" "${recovery_dir}/bash.bashrc"
  run_as_root cp -a -- "$installer_backup" "${recovery_dir}/bash.bashrc.backup-before-nix"

  if run_as_root grep -Eiq '(^|[^[:alnum:]_])nix([^[:alnum:]_]|$)|NIX_' "$installer_backup"; then
    fail "${installer_backup} contains Nix-related content; preserved copies are in ${recovery_dir}"
  fi

  log "Restoring the clean pre-Nix shell profile before installation"
  run_as_root mv -- "$installer_backup" "$bashrc"
}

validate_repository() {
  [ -d "${repo_path}/.git" ] || fail "deployment must run from a Git checkout: ${repo_path}"
  [ -f "${repo_path}/flake.nix" ] || fail "flake.nix is missing from repository: ${repo_path}"
}

prepare_local_config() {
  local config_file="${repo_path}/config.local.toml"
  local action=

  if [ ! -e "$config_file" ]; then
    action="Creating"
  elif [ -f "$config_file" ] &&
    grep -Fqx '[git]\nusername = ""\nemail = ""\n' "$config_file"; then
    action="Repairing malformed"
  else
    return
  fi

  log "${action} private local configuration"
  (
    umask 077
    printf '[git]\nusername = ""\nemail = ""\n' > "$config_file"
    chmod 600 "$config_file"
  )
}

activate_home_manager() {
  local backup_extension

  export USER="${USER:-$(id -un)}"
  export NIX_CONFIG_REPO="$repo_path"
  export NIX_CONFIG_BRANCH="$repo_branch"
  export NIX_CONFIG_FLAKE="$flake_config"
  export NIX_SYSTEM="${NIX_SYSTEM:-$(detect_nix_system)}"
  if [ -n "${NIX_CONFIG:-}" ]; then
    export NIX_CONFIG="${NIX_CONFIG}"$'\n''extra-experimental-features = nix-command flakes'
  else
    export NIX_CONFIG="extra-experimental-features = nix-command flakes"
  fi

  backup_extension="hm-backup-$(date -u +%Y%m%dT%H%M%SZ)-$$"
  log "Activating ${flake_config} for ${USER} on ${NIX_SYSTEM}"
  nix --extra-experimental-features "nix-command flakes" \
    run github:nix-community/home-manager -- \
    switch --impure -b "$backup_extension" --flake "${repo_path}#${flake_config}"
}

configure_login_shell() {
  local zsh_path="/usr/bin/zsh"
  local current_shell

  [ -x "$zsh_path" ] || fail "Ubuntu ZSH is not installed at ${zsh_path}"
  grep -Fxq "$zsh_path" /etc/shells || fail "${zsh_path} is not registered in /etc/shells"

  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [ "$current_shell" = "$zsh_path" ]; then
    return
  fi

  log "Setting ${zsh_path} as the login shell for ${USER}"
  run_as_root chsh -s "$zsh_path" "$USER"
}

main() {
  install_prerequisites
  validate_repository
  prepare_local_config
  install_nix
  activate_home_manager
  configure_login_shell
  log "Ubuntu CLI environment is ready. Start a new login shell."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi

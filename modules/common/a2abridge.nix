# a2abridge discovery service and binary management, shared by macOS and Ubuntu.
{ hostVars, lib, pkgs, ... }:

let
  a2aBin = "${hostVars.home}/.a2abridge/bin/a2abridge";
  version = "4.0.3";
in
{
  home.sessionPath = [
    "${hostVars.home}/.a2abridge/bin"
  ];

  # Download/install a2abridge binary if missing or different version
  home.activation.a2abridgeBinary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    need_install=0
    if [ ! -x "${a2aBin}" ]; then
      need_install=1
    elif ! "${a2aBin}" version 2>/dev/null | grep -q "${version}"; then
      need_install=1
    fi

    if [ "$need_install" -eq 1 ]; then
      echo "Installing / updating a2abridge v${version}..."
      $DRY_RUN_CMD mkdir -p "${hostVars.home}/.a2abridge/bin"
      os="$(uname -s | tr '[:upper:]' '[:lower:]')"
      arch="$(uname -m)"
      case "$arch" in
        x86_64|amd64)  arch=amd64 ;;
        aarch64|arm64) arch=arm64 ;;
        *) echo "a2abridge: unsupported arch $arch" >&2; exit 0 ;;
      esac
      tarball="a2abridge_${version}_''${os}_''${arch}.tar.gz"
      url="https://github.com/vbcherepanov/a2abridge/releases/download/v${version}/$tarball"
      tmpdir="$(mktemp -d)"
      if ${pkgs.curl}/bin/curl -fsSL "$url" | tar -xz -C "$tmpdir" 2>/dev/null; then
        $DRY_RUN_CMD mv "$tmpdir/a2abridge" "${a2aBin}"
        $DRY_RUN_CMD chmod +x "${a2aBin}"
        echo "✓ a2abridge v${version} installed to ${a2aBin}"
      else
        echo "a2abridge: download failed from $url" >&2
      fi
      rm -rf "$tmpdir"
    fi
  '';

  # Systemd user service for discovery daemon on Linux
  systemd.user.services.a2abridge-directory = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Local A2A 1.0 discovery service for AI coding agents";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${a2aBin} directory --addr 127.0.0.1:7777";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # Launchd user agent for discovery daemon on macOS
  launchd.agents.a2abridge-directory = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        a2aBin
        "directory"
        "--addr"
        "127.0.0.1:7777"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${hostVars.home}/Library/Logs/a2abridge-directory.log";
      StandardErrorPath = "${hostVars.home}/Library/Logs/a2abridge-directory.err.log";
    };
  };
}

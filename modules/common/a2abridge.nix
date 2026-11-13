# a2abridge binary, discovery service and the agent-mesh tooling shared by all agent CLIs
# (macOS and Ubuntu). Per-agent MCP registration lives in claude/codex/agy/kimi.nix.
{ hostVars, lib, pkgs, ... }:

let
  a2aBin = "${hostVars.home}/.a2abridge/bin/a2abridge";
  version = "4.0.3";
  # From the release's checksums.txt; update together with `version`.
  sha256 = {
    linux_amd64 = "5589c10178c4311c42c65bc4075877fe307067ac5975161fe3beaafb889b38a2";
    linux_arm64 = "43484e8f3c46a9b6c6adcdacb8cf2c95729c95d0bb3f89674a2cc16de99a10bd";
    darwin_amd64 = "b096a11dcb62727cbd02dd96dd0f8b15ecbbd72326976dbb97ce04015ae8f624";
    darwin_arm64 = "6f5b610fecc6eede9742648a6a933f25d7f486a00d884d9fe366219691dd5fa7";
  };
  sha256Cases = lib.concatStrings (
    lib.mapAttrsToList (platform: hash: "      ${platform}) expected=${hash} ;;\n") sha256
  );
in
{
  home.sessionPath = [
    "${hostVars.home}/.a2abridge/bin"
  ];

  home.file = {
    ".local/bin/a2a-bridge" = {
      source = ../../scripts/a2a-bridge;
      executable = true;
    };
    ".local/bin/agent-run" = {
      source = ../../scripts/agent-run;
      executable = true;
    };
    ".local/bin/agent-session" = {
      source = ../../scripts/agent-session;
      executable = true;
    };
    ".local/bin/agent-quota" = {
      source = ../../scripts/agent-quota;
      executable = true;
    };
    ".local/bin/a2a-wait" = {
      source = ../../scripts/a2a-wait;
      executable = true;
    };
    ".local/bin/agent-tmux" = {
      source = ../../scripts/agent-tmux;
      executable = true;
    };

    # Skill + global instructions for agents reading ~/.agents (agy, kimi, codex).
    ".agents/AGENTS.md".source = ../../dotfiles/agents/AGENTS.md;
    ".agents/skills/a2a-bridge" = {
      source = ../../dotfiles/agents/skills/a2a-bridge;
      recursive = true;
    };
  };

  # Download/install a2abridge binary if missing or different version
  home.activation.a2abridgeBinary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    need_install=0
    if [ ! -x "${a2aBin}" ]; then
      need_install=1
    elif ! "${a2aBin}" version 2>/dev/null | grep -q "${version}"; then
      need_install=1
    fi

    if [ "$need_install" -eq 1 ] && [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would install a2abridge v${version} to ${a2aBin}"
    elif [ "$need_install" -eq 1 ]; then
      echo "Installing / updating a2abridge v${version}..."
      $DRY_RUN_CMD mkdir -p "${hostVars.home}/.a2abridge/bin"
      os="$(uname -s | tr '[:upper:]' '[:lower:]')"
      arch="$(uname -m)"
      case "$arch" in
        x86_64|amd64)  arch=amd64 ;;
        aarch64|arm64) arch=arm64 ;;
      esac
      expected=""
      case "''${os}_''${arch}" in
${sha256Cases}      esac
      tarball="a2abridge_${version}_''${os}_''${arch}.tar.gz"
      url="https://github.com/vbcherepanov/a2abridge/releases/download/v${version}/$tarball"
      tmpdir="$(mktemp -d)"
      if [ -z "$expected" ]; then
        echo "a2abridge: no pinned checksum for ''${os}_''${arch}, skipping install" >&2
      elif ! ${pkgs.curl}/bin/curl -fsSL "$url" -o "$tmpdir/$tarball"; then
        echo "a2abridge: download failed from $url" >&2
      elif [ "$(${pkgs.coreutils}/bin/sha256sum "$tmpdir/$tarball" | ${pkgs.coreutils}/bin/cut -d' ' -f1)" != "$expected" ]; then
        echo "a2abridge: checksum mismatch for $tarball, not installing" >&2
      elif PATH="${pkgs.gzip}/bin:$PATH" ${pkgs.gnutar}/bin/tar -xzf "$tmpdir/$tarball" -C "$tmpdir"; then
        $DRY_RUN_CMD mv "$tmpdir/a2abridge" "${a2aBin}"
        $DRY_RUN_CMD chmod +x "${a2aBin}"
        echo "✓ a2abridge v${version} installed to ${a2aBin}"
      fi
      rm -rf "$tmpdir"
    fi
  '';

  # Systemd user service for discovery daemon on Linux
  systemd.user.services.a2abridge-directory = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Local A2A 1.0 discovery service for AI coding agents";
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

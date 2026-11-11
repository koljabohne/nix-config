# Agent skills via skillshare, shared by macOS and Ubuntu.
#
# ~/nix is the source of truth: the activation makes skillshare install every
# source listed here and syncs them into all detected agent CLIs (Claude,
# Codex, Agy, Kimi and Gemini via ~/.agents/skills; per-tool targets would
# show every skill twice to tools that also read ~/.agents). Skills installed by hand
# with `skillshare install` stay untouched (merge mode).
#
# Update remote skills: `skillshare update --all && skillshare sync`.
{ hostVars, lib, pkgs, ... }:

let
  version = "0.24.5";
  # From the release's checksums.txt; update together with `version`.
  sha256 = {
    x86_64-linux = "5f776f0386e97dd4f77aaba108b4da939a0ffba35e133c0aa5260759ea03b643";
    aarch64-linux = "d769313f7e1e3167265d1b29b3855b9e0389ced807607af6d5ef03ce84bca1e1";
  };
  platform = {
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
  };
  system = pkgs.stdenv.hostPlatform.system;

  # macOS gets skillshare from Homebrew (modules/macos/system/homebrew.nix).
  skillshare = pkgs.stdenvNoCC.mkDerivation {
    pname = "skillshare";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_${platform.${system}}.tar.gz";
      sha256 = sha256.${system};
    };
    sourceRoot = ".";
    installPhase = ''
      install -Dm755 skillshare $out/bin/skillshare
    '';
    meta.platforms = builtins.attrNames sha256;
  };

  # Remote sources (skillshare `install` syntax). Installed once, then only
  # updated on request so a switch needs no network.
  remoteSources = [
    "mattpocock/skills"
  ];

  # Own skills: every directory in ~/nix/skills, re-installed on each switch
  # so edits in the repo reach all agents.
  localSkillsDir = "${hostVars.repoPath}/skills";
  localSkills = builtins.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir ../../skills));
in
{
  home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux skillshare;

  home.activation.skillshare = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${lib.makeBinPath [ pkgs.git pkgs.gnugrep pkgs.coreutils ]}:${lib.optionalString pkgs.stdenv.hostPlatform.isLinux "${skillshare}/bin:"}/opt/homebrew/bin:/usr/local/bin:$PATH"
    if ! command -v skillshare >/dev/null 2>&1; then
      echo "skillshare: not installed, skipping skill sync" >&2
    elif [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "would install ${toString (remoteSources ++ localSkills)} via skillshare and sync"
    else
      ss_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/skillshare"
      meta="$ss_dir/skills/.metadata.json"
      log="$ss_dir/activation.log"
      mkdir -p "$ss_dir"
      echo "=== $(date -Is)" >> "$log"
      ss() { skillshare "$@" >> "$log" 2>&1; }

      if [ ! -f "$ss_dir/config.yaml" ]; then
        ss init --no-copy --no-git --no-skill --targets claude,universal || echo "skillshare: init failed" >&2
      fi

      for src in ${lib.escapeShellArgs remoteSources}; do
        # github shorthand is recorded as github.com/<owner>/<repo>/...
        if ! grep -q "\"github.com/$src/" "$meta" 2>/dev/null; then
          echo "skillshare: installing $src"
          ss install "$src" --all || echo "skillshare: install of $src failed" >&2
        fi
      done

      for name in ${lib.escapeShellArgs localSkills}; do
        ss install "${localSkillsDir}/$name" --update || echo "skillshare: install of $name failed" >&2
      done

      ss sync --quiet || echo "skillshare: sync failed, see $log" >&2
    fi
  '';
}

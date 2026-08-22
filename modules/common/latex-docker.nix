# Baut die LaTeX-Docker-Images aus docker/latex/.
# Stellt nur ein Kommando bereit - Docker selbst wird nicht von Nix mitgebracht,
# sondern zur Laufzeit gesucht (macOS: Docker Desktop, siehe homebrew.nix).
{ pkgs, ... }:

let
  # Build-Kontext landet als immutable Store-Pfad im Nix-Store.
  context = ../../docker/latex;

  latex-image = pkgs.writeShellApplication {
    name = "latex-image";

    text = ''
      context="${context}"
      base_tag="latex-base"
      cli_tag="latex-cli"

      if ! command -v docker >/dev/null 2>&1; then
        echo "latex-image: docker nicht gefunden." >&2
        echo "  macOS: Docker Desktop wird über homebrew.nix installiert -" >&2
        echo "         einmal starten, damit die CLI verlinkt wird." >&2
        exit 127
      fi

      if ! docker info >/dev/null 2>&1; then
        echo "latex-image: Docker ist installiert, aber der Daemon läuft nicht." >&2
        echo "  Docker Desktop starten und erneut versuchen." >&2
        exit 69
      fi

      extra_args=()
      case "''${1-}" in
        --no-cache) extra_args+=(--no-cache) ;;
        "") ;;
        *) echo "Aufruf: latex-image [--no-cache]" >&2; exit 64 ;;
      esac

      echo "==> Baue $base_tag (TeX Live, dauert beim ersten Mal einige Minuten)"
      docker build "''${extra_args[@]}" \
        -f "$context/Dockerfile.base" \
        -t "$base_tag" \
        "$context"

      echo "==> Baue $cli_tag"
      docker build "''${extra_args[@]}" \
        -f "$context/Dockerfile.cli" \
        --build-arg "BASE_IMAGE=$base_tag" \
        -t "$cli_tag" \
        "$context"

      echo "==> Fertig:"
      docker image ls --filter "reference=$base_tag" --filter "reference=$cli_tag" \
        --format '    {{.Repository}}:{{.Tag}}  {{.Size}}'
    '';
  };
in
{
  home.packages = [ latex-image ];
}

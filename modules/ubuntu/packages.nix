# Package assembly for the Ubuntu CLI profile.
{ pkgs, ... }:

let
  commonPackages = import ../common/packages.nix { inherit pkgs; };

  herdrWrapper = pkgs.writeShellScriptBin "herdr" ''
    if [ -x "$HOME/.local/bin/herdr" ]; then
      exec "$HOME/.local/bin/herdr" "$@"
    else
      echo "herdr not found in ~/.local/bin" >&2
      exit 1
    fi
  '';

  hcWrapper = pkgs.writeShellScriptBin "hc" ''
    if [ -x "$HOME/.local/bin/hc" ]; then
      exec "$HOME/.local/bin/hc" "$@"
    elif [ -x "$HOME/.local/bin/herdr-core" ]; then
      exec "$HOME/.local/bin/herdr-core" "$@"
    else
      echo "hc not found in ~/.local/bin" >&2
      exit 1
    fi
  '';
in
{
  # Add Ubuntu-only packages after commonPackages when needed.
  home.packages = commonPackages ++ [
    herdrWrapper
    hcWrapper
  ] ++ (with pkgs; [
    python312
    uv
    bun
  ]);
}

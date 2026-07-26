# Package assembly for the Ubuntu CLI profile.
{ pkgs, ... }:

let
  commonPackages = import ../common/packages.nix { inherit pkgs; };
in
{
  # Add Ubuntu-only packages after commonPackages when needed.
  home.packages = commonPackages ++ (with pkgs; [
    python312
    uv
  ]);
}

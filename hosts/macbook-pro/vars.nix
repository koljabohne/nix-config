let
  user = "local-user";
  home = "/Users/${user}";
in
{
  inherit user home;

  system = "aarch64-darwin";
  configurationName = "MacBook-Pro";
  repoPath = "${home}/nix";
}

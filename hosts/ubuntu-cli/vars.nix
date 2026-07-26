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

let
  requireEnv =
    name:
    let
      value = builtins.getEnv name;
    in
    if value == "" then
      throw "Ubuntu CLI requires ${name}; evaluate it with --impure as the target user"
    else
      value;

  user = requireEnv "USER";
  home = requireEnv "HOME";
  configuredRepoPath = builtins.getEnv "NIX_CONFIG_REPO";
  configuredSystem = builtins.getEnv "NIX_SYSTEM";
in
{
  inherit user home;

  system =
    if configuredSystem == "" then
      "x86_64-linux"
  else
      configuredSystem;
  configurationName = "ubuntu-cli";
  branch = "main";
  repoPath =
    if configuredRepoPath == "" then
      "${home}/nix"
    else
      configuredRepoPath;
}

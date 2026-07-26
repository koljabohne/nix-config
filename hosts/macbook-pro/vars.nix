{ localConfig, repoPath }:

let
  macos = localConfig.macos or { };
  user =
    macos.username or (throw "config.local.toml: [macos].username is required");
  home =
    macos.home or (throw "config.local.toml: [macos].home is required");
in
{
  inherit user home repoPath;

  system = "aarch64-darwin";
  configurationName = "MacBook-Pro";
}

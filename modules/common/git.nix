# Git configuration shared by macOS and Ubuntu.
{ lib, localConfig, ... }:

let
  localGit = localConfig.git or { };
  username = localGit.username or "";
  email = localGit.email or "";
  hasUsername = username != "";
  hasEmail = email != "";
in
{
  assertions = [
    {
      assertion = hasUsername == hasEmail;
      message = "config.local.toml: [git] requires both username and email";
    }
  ];

  programs.git = {
    enable = true;
    signing.format = null;

    settings =
      {
        init = {
          defaultBranch = "main";
        };

        alias = {
          s = "status";
          a = "add";
        };
      }
      // lib.optionalAttrs (hasUsername && hasEmail) {
        user = {
          name = username;
          inherit email;
        };
      };

    ignores = [
      ".DS_Store"
      "._.DS_Store"
      ".vscode"
      "__pychache__/"
    ];
  };

  # Force overwrite existing git ignore file
  xdg.configFile."git/ignore".force = true;
}

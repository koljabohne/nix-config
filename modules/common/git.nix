# Git configuration shared by macOS and Ubuntu.
{ config, ... }:

{
  programs.git = {
    enable = true;
    signing.format = null;

    settings = {
      init = {
        defaultBranch = "main";
      };

      alias = {
        s = "status";
        a = "add";
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

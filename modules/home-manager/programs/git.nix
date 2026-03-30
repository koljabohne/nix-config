{ config, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "PracticalPassion";
        email = "PracticalPassion@users.noreply.github.com";
      };

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

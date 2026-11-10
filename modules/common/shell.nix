# Shell settings shared by macOS and Ubuntu.
{ hostVars, ... }:

{
  home.sessionVariables = {
    hi_can = "Hi barbie";
    EDITOR = "nvim";
    NIX_CONFIG_REPO = hostVars.repoPath;
  };
}

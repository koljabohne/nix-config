# macOS Homebrew packages and applications.
{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "mas"
      "gnu-sed"
      "poppler"
      "qpdf"
      "nvm"
      "pandoc"
      "tesseract"
      "tesseract-lang"
      "cmake"
      "youtubedr"
      "yt-dlp"
      "dua-cli"
      "zsh-autosuggestions"
      "mole"
      "rclone"
      "zsh-syntax-highlighting"
    ];

    casks = [
      "inkscape"
      "vorssaint"
      "fluidvoice"
      "firefox"
      "KeePassXC"
      #"rstudio"
      # "r-app"
      "opera"
      "xquartz"
      "aldente"
      "chromedriver"
      "MonitorControl"
      "keyclu"
      "anki"
      "betterdisplay"
      "macs-fan-control"
      "cyberduck"
      "alt-tab"
      "miniconda"
      "deepl"
      "iterm2"
      "docker-desktop"
      "ghostty"
    ];

    masApps = {
      # "Xcode" = 497799835;
      # "Magnet" = 441258766;
    };

    onActivation.cleanup = "none";
    onActivation.upgrade = true;
  };
}

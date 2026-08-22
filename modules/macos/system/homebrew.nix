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
      "zsh-syntax-highlighting"
    ];

    casks = [
      "inkscape"
      "firefox"
      "KeePassXC"
      "rstudio"
      "r-app"
      "opera"
      "xquartz"
      "aldente"
      "chromedriver"
      "MonitorControl"
      "obsidian"
      "keyclu"
      "anki"
      "betterdisplay"
      "cyberduck"
      "alt-tab"
      "miniconda"
      "deepl"
      "iterm2"
      "docker-desktop"
    ];

    masApps = {
      # "Xcode" = 497799835;
      # "Magnet" = 441258766;
    };

    onActivation.cleanup = "zap";
    onActivation.upgrade = true;
  };
}

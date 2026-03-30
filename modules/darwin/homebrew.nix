{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "mas"
      "gnu-sed"
      "poppler"
      "nvm"
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
      "firefox"
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

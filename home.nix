{ config, pkgs, ... }:

let 
    vars = import ./vars.nix;
in
{
    home.username = vars.user;
    home.homeDirectory = vars.home;
    
    home.packages = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.geist-mono
        pkgs.python312
        pkgs.poetry
    ];

    home.file = {
        ".config/nvim".source = ./dotfiles/nvim; # Habe "./" ergänzt für relative Pfade
        ".zshrc".source = ./dotfiles/zshrc;
        ".config/nix/nix.conf".source = ./dotfiles/nix.conf;
    };

    programs.git.settings = {
      enable = true;
      userName = "PracticalPassion";
      userEmail = "PracticalPassion@users.noreply.github.com";
      extraConfig.init.defaultBranch = "main";
      aliases = { "s" = "status"; "a" = "add"; };
      ignores = [ ".DS_Store" "._.DS_Store" ".vscode" "__pychache__/" ];
    };

    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      
      # TIPP: Setze dies auf false, damit Nix volle Kontrolle hat und
      # alte manuell installierte Extensions nicht stören.
      # mutableExtensionsDir = false; 

      profiles.default = {
        
        extensions = with pkgs.vscode-marketplace; [
          
          charliermarsh.ruff
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-toolsai.jupyter-keymap
          ms-python.debugpy
          ms-toolsai.jupyter-renderers
          anthropic.claude-code

          
          # Tools
          ms-vscode.remote-explorer
          ms-vscode-remote.remote-ssh
          ms-azuretools.vscode-containers
          ms-azuretools.vscode-docker
          eamodio.gitlens
          editorconfig.editorconfig
          christian-kohler.path-intellisense
          gruntfuggly.todo-tree
          yzhang.markdown-all-in-one
          redhat.vscode-yaml
          alefragnani.bookmarks
          aaron-bond.better-comments
          janisdd.vscode-edit-csv
          openai.chatgpt
          
          # Nix
          bbenoist.nix
          jnoortheen.nix-ide
          
          # CSV
          mechatroner.rainbow-csv

          # PDF Viewer
          tomoki1207.pdf

          # Icons
          pkief.material-icon-theme
          helgardrichard.helium-icon-theme
        ] ;
        userSettings = {
            "update.mode"= "none";
            "terminal.integrated.inheritEnv" = false;
            "terminal.integrated.suggest.enabled"= false;
            "settingsSync.ignoredExtensions" = [];
            "settingsSync.keybindingsPerPlatform" = false;
            "explorer.confirmDragAndDrop" = false;
            
            # UI
            "chat.disableAIFeatures" = true;
            "workbench.iconTheme" = "helium-icon-theme";
            
            # Fonts
            "terminal.integrated.fontFamily" = "JetBrains Mono";
            "terminal.integrated.fontSize" = 13;
            "terminal.integrated.lineHeight" = 1.1;
            "editor.fontFamily" = "Geist Mono";
            "editor.fontLigatures" = true;

            # Formatting
            "editor.formatOnSave" = true;
            "[python]" = {
            "analysis.typeCheckingMode" = "basic";
            "formatting.provider" = "none";
                "editor.defaultFormatter" = "charliermarsh.ruff";
              "editor.formatOnSave"= true;
              "defaultInterpreterPath"= "/opt/homebrew/Caskroom/miniconda/base/bin/python";
            };
            "ruff.format.enabled" = true;
            "[json]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
            };
              "[css]"= {
                "editor.defaultFormatter"= "vscode.css-language-features";
                };
                  "[nix]"= {
            "editor.formatOnSave"= false;
                "editor.defaultFormatter"= "jnoortheen.nix-ide";
            # "editor.defaultFormatter"= "jnoortheen.nix-ide";
        };
          "[javascript]"= {
    "editor.defaultFormatter"= "vscode.typescript-language-features";
  };
        };

        keybindings = [
          {
            key = "cmd+d";
            command = "workbench.action.terminal.toggleTerminal";
          }
          {
              "key"= "tab";
              "command"= "editor.action.inlineSuggest.commit";
              "when"= "textInputFocus && inlineSuggestionHasIndentationLessThanTabSize && inlineSuggestionVisible && !editorTabMovesFocus";
          }
          {
              "key"= "cmd+n";
              "command"= "explorer.newFile";
          }
          {
              "key"= "cmd+d";
              "command"= "workbench.action.terminal.focus";
          }
          {
              "key"= "cmd+d";
              "command"= "workbench.action.focusActiveEditorGroup";
              "when"= "terminalFocus";
          }
          {
              "key"= "shift+alt+cmd+n";
              "command"= "github.copilot.nextPanelSolution";
          }
          {
              "key"= "shift+alt+cmd+p";
              "command"= "github.copilot.previousPanelSolution";
          }
          {
              "key"= "cmd+i";
              "command"= "-interactiveEditor.start";
              "when"= "interactiveEditorHasProvider && !editorReadonly";
          }
          {
              "key"= "ctrl+cmd+c";
              "command"= "interactiveEditor.start";
              "when"= "interactiveEditorHasProvider && !editorReadonly";
          }
          {
              "key"= "cmd+k i";
              "command"= "-interactiveEditor.start";
              "when"= "interactiveEditorHasProvider && !editorReadonly";
          }
          {
              "key"= "cmd+i";
              "command"= "-inlineChat.start";
              "when"= "inlineChatHasProvider && !editorReadonly";
          }
          {
              "key"= "ctrl+cmd+p";
              "command"= "ltex.checkCurrentDocument";
          }
          {
              "key"= "ctrl+cmd+a";
              "command"= "ltex.checkAllDocumentsInWorkspace";
          }
          {
              "key"= "ctrl+cmd+r";
              "command"= "ltex.resetAndRestart";
          }
          {
              "key"= "ctrl+cmd+n";
              "command"= "merge.goToNextUnhandledConflict";
          }
          {
              "key"= "ctrl+cmd+s";
              "command"= "workbench.action.quickTextSearch";
          }
          {
              "key"= "shift+ctrl+down";
              "command"= "editor.action.nextMatchFindAction";
              "when"= "editorFocus";
          }
          {
              "key"= "shift+ctrl+up";
              "command"= "editor.action.previousMatchFindAction";
              "when"= "editorFocus";
          }
        ];
      };
    };

    home.stateVersion = "24.05";

    home.sessionVariables = {
      hi_can = "Hi barbie";
      EDITOR = "nvim";
      HISTFILE = "${config.home.homeDirectory}/.prompt_history";
      HISTFILESIZE = "5000";
    };

    programs.home-manager.enable = true;
}

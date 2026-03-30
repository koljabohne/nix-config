{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        # Python
        charliermarsh.ruff
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap
        ms-python.debugpy
        ms-toolsai.jupyter-renderers
        anthropic.claude-code

        # LaTeX
        xrimson.bibtex-tidy
        james-yu.latex-workshop

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
      ];

      userSettings = {
        "update.mode" = "none";
        "terminal.integrated.inheritEnv" = false;
        "terminal.integrated.suggest.enabled" = false;
        "settingsSync.ignoredExtensions" = [];
        "settingsSync.keybindingsPerPlatform" = false;
        "explorer.confirmDragAndDrop" = false;

        # LaTeX
        "latex-workshop.bibtex-format.sort.enabled" = true;

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
          "editor.formatOnSave" = true;
          "defaultInterpreterPath" = "/opt/homebrew/Caskroom/miniconda/base/bin/python";
        };
        "ruff.format.enabled" = true;
        "[json]" = {
          "editor.defaultFormatter" = "vscode.json-language-features";
        };
        "[css]" = {
          "editor.defaultFormatter" = "vscode.css-language-features";
        };
        "[nix]" = {
          "editor.formatOnSave" = false;
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "[javascript]" = {
          "editor.defaultFormatter" = "vscode.typescript-language-features";
        };
        "[bibtex]" = {
          "editor.defaultFormatter" = "James-Yu.latex-workshop";
        };
      };

      keybindings = [
        {
          key = "cmd+d";
          command = "workbench.action.terminal.toggleTerminal";
        }
        {
          key = "tab";
          command = "editor.action.inlineSuggest.commit";
          when = "textInputFocus && inlineSuggestionHasIndentationLessThanTabSize && inlineSuggestionVisible && !editorTabMovesFocus";
        }
        {
          key = "cmd+n";
          command = "explorer.newFile";
        }
        {
          key = "cmd+d";
          command = "workbench.action.terminal.focus";
        }
        {
          key = "cmd+d";
          command = "workbench.action.focusActiveEditorGroup";
          when = "terminalFocus";
        }
        {
          key = "shift+alt+cmd+n";
          command = "github.copilot.nextPanelSolution";
        }
        {
          key = "shift+alt+cmd+p";
          command = "github.copilot.previousPanelSolution";
        }
        {
          key = "cmd+i";
          command = "-interactiveEditor.start";
          when = "interactiveEditorHasProvider && !editorReadonly";
        }
        {
          key = "ctrl+cmd+c";
          command = "interactiveEditor.start";
          when = "interactiveEditorHasProvider && !editorReadonly";
        }
        {
          key = "cmd+k i";
          command = "-interactiveEditor.start";
          when = "interactiveEditorHasProvider && !editorReadonly";
        }
        {
          key = "cmd+i";
          command = "-inlineChat.start";
          when = "inlineChatHasProvider && !editorReadonly";
        }
        {
          key = "ctrl+cmd+p";
          command = "ltex.checkCurrentDocument";
        }
        {
          key = "ctrl+cmd+a";
          command = "ltex.checkAllDocumentsInWorkspace";
        }
        {
          key = "ctrl+cmd+r";
          command = "ltex.resetAndRestart";
        }
        {
          key = "ctrl+cmd+n";
          command = "merge.goToNextUnhandledConflict";
        }
        {
          key = "ctrl+cmd+s";
          command = "workbench.action.quickTextSearch";
        }
        {
          key = "shift+ctrl+down";
          command = "editor.action.nextMatchFindAction";
          when = "editorFocus";
        }
        {
          key = "shift+ctrl+up";
          command = "editor.action.previousMatchFindAction";
          when = "editorFocus";
        }
      ];
    };
  };
}

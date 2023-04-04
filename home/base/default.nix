{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib) optionalString mkMerge mkIf;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  home = {
    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    sessionVariables = {
      CLICOLOR = 1;
      LANG = "en_GB.UTF-8";
      LESS = "R";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=240";
    };

    file.".indentconfig.yaml".text = ''
      paths:
      - ${config.home.homeDirectory}/.indentsettings.yaml
    '';

    file.".indentsettings.yaml".text = ''
      defaultIndent: "  "
      verbatimEnvironments:
        listing: 1
        lstlisting: 1
        minted: 1
        tikzpicture: 1
        verbatim: 1
    '';
  };

  xdg = mkMerge [
    {
      configFile."git/ignore".source = ../../static/gitignore;

      configFile."wezterm/wezterm.lua".text = ''
        local wezterm = require 'wezterm';

        local mykeys = {
          -- Reload the config file
          { key = "r", mods = "LEADER", action = "ReloadConfiguration" },

          -- Enter and exit fullscreen
          { key = "Enter", mods = "ALT", action = "ToggleFullScreen" },

          -- Create and close tabs
          { key = "c", mods = "LEADER", action = wezterm.action { SpawnCommandInNewTab = { domain = "CurrentPaneDomain", cwd = "~" } } },
          { key = "k", mods = "LEADER", action = wezterm.action { CloseCurrentTab = { confirm = true } } },

          -- Select next and previous tabs
          { key = "n", mods = "LEADER", action = wezterm.action { ActivateTabRelative = 1 } },
          { key = "p", mods = "LEADER", action = wezterm.action { ActivateTabRelative = -1 } },

          -- Create horizontal or vertical splits (close by sending EOF with Ctrl-D)
          { key = "|", mods = "LEADER", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
          { key = "|", mods = "LEADER|SHIFT", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
          { key = "-", mods = "LEADER", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },

          -- Move between splits
          { key = "h", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Left" } },
          { key = "j", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Down" } },
          { key = "k", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Up" } },
          { key = "l", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Right" } },

          -- Copy and paste text
          {
            key = "c",
            mods = "SUPER",
            action = wezterm.action.CopyTo "ClipboardAndPrimarySelection"
          },
          {
            key = "v",
            mods = "SUPER",
            action = wezterm.action.PasteFrom "Clipboard"
          },

          -- Zoom in and out
          { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
          { key = "=", mods = "CTRL", action = "IncreaseFontSize" },
          { key = "0", mods = "CTRL", action = "ResetFontSize" },
        }

        -- Insert bindings to select each tab
        for i = 1, 9 do
          table.insert(mykeys, {
            key = tostring(i),
            mods = "LEADER",
            action = wezterm.action { ActivateTab = i - 1 },
          })
        end

        table.insert(mykeys, {
          key = "0",
          mods = "LEADER",
          action = wezterm.action { ActivateTab = 9 },
        })

        wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
          local pane = tab.active_pane
          local cwd = string.match(pane.current_working_dir, "/([^/]+)/$")
          if cwd ~= nil then
            return {
              {Text=" " .. (tab.tab_index + 1) .. ": " .. tab.active_pane.title .. " | " .. cwd .. " "},
            }
          end
          return tab.active_pane.title
        end)

        return {
          color_scheme = "OneHalfDark",
          font = wezterm.font("Iosevka", { weight = "Light", }),
          enable_scroll_bar = true,

          -- colors = {
          --   ansi = {
          --     '#383e49',
          --     '#e06c75',
          --     '#98c379',
          --     '#e5c07b',
          --     '#61afef',
          --     '#c678dd',
          --     '#56b6c2',
          --     '#dcdfe4',
          --   },
          -- },

          exit_behavior = "Close",

          -- The leader key (Ctrl-Space) must be pressed before any bindings with the LEADER modifier
          leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 },

          disable_default_key_bindings = true,
          keys = mykeys,

          warn_about_missing_glyphs = false,

          check_for_updates = false,

          -- unix_domains = {
          --   {
          --     name = "talitha",
          --     proxy_command = { "ssh", "-T", "-A", "talitha", "wezterm", "cli", "proxy" },
          --   },
          -- },

          ${optionalString isDarwin ''
          font_size = 16.0,
          window_decorations = "RESIZE",
          native_macos_fullscreen_mode = true,
          ''}
        }
      '';

      configFile."helix/config.toml".text = ''
        theme = "onedark"

        [editor]
        line-number = "relative"
        true-color = true
        auto-pairs = false
        cursor-shape = { insert = "bar", normal = "block", select = "block" }

        [lsp]
        display-messages = true
      '';
    }
  ];

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      stdlib = ''
        # stolen from @i077; store .direnv in cache instead of project dir
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "${config.xdg.cacheHome}"/direnv/layouts/
            echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };

    zoxide.enable = true;
    starship.enable = true;

    fzf = rec {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;

      defaultCommand = "${pkgs.fd}/bin/fd -H --type f";
      defaultOptions = [ "--height 50%" "--border" ];
      fileWidgetCommand = "${defaultCommand}";
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --color=always --plain --line-range=:200 {}'"
      ];
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
      changeDirWidgetOptions =
        [ "--preview '${pkgs.tree}/bin/tree -C {} | head -200'" ];
    };

    zsh =
      let
        mkZshPlugin = { pkg, file ? "${pkg.pname}.plugin.zsh" }: rec {
          name = pkg.pname;
          src = pkg.src;
          inherit file;
        };

        functions = ''
          # blank aliases
          typeset -a baliases
          baliases=()

          balias() {
            alias $@
            args="$@"
            args=''${args%%\=*}
            baliases+=(''${args##* })
          }

          # ignored aliases
          typeset -a ialiases
          ialiases=()

          ialias() {
            alias $@
            args="$@"
            args=''${args%%\=*}
            ialiases+=(''${args##* })
          }

          # functionality
          expand-alias-space() {
            [[ $LBUFFER =~ "\<(''${(j:|:)baliases})\$" ]]; insertBlank=$?
            if [[ ! $LBUFFER =~ "\<(''${(j:|:)ialiases})\$" ]]; then
              zle _expand_alias
            fi
            zle self-insert
            # if [[ "$insertBlank" = "0" ]]; then
            #   zle backward-delete-char
            # fi
          }
          zle -N expand-alias-space

          bindkey " " expand-alias-space
          bindkey -M isearch " " magic-space
        '';

        aliases = ''
          # Aliases that are expanded inline (without adding a space after)
          balias lsl="exa -al"
          balias lst="exa -alT -I '.git|target'"
          balias lsta="exa -alT"

          # Status/info
          balias ghg='git status'
          balias ghf='git hist'
          balias ghd='git diff --color-moved'
          balias ghs='git diff --color-moved --cached'
          balias gha='git stash list'

          # Changes
          balias gjg='git add'
          balias gjf='git checkout --'
          balias gjd='git add -p'
          balias gjs='git reset HEAD --'
          balias gja='git reset -p'

          # Commit
          balias gkg='git commit'
          balias gkf='git commit --amend'
          balias gkd='git commit -m'

          # Push/pull
          balias glg='git push'
          balias glf='git push --force-with-lease'
          balias gld='git push -u'
          balias gls='git pull'
          balias gla='git fetch -p --all'

          # Rebase
          balias gug='git rebase'
          balias guf='git rebase --onto'
          balias gud='git rebase -i'
          balias gus='git rebase --continue'
          balias gua='git rebase --abort'

          # Branch/checkout
          balias gig='git checkout'
          balias gif='git branch -d'
          balias gid='git checkout -b'
          balias gis='git branch'
          balias gia='git branch -r'

          # Stash
          balias gog='git stash push'
          balias gof='git stash drop'
          balias god='git stash push --keep-index'
          balias gos='git stash pop'
          balias goa='git stash apply'

          # Bisect
          balias gyg='git bisect start'
          balias gyf='git bisect reset'
          balias gyd='git bisect good'
          balias gys='git bisect bad'
          balias gya='git bisect run'

          # Merge
          balias gmg='git merge'
          balias gmf='git merge --squash'
          balias gmd='git merge --signoff'
          balias gms='git merge --continue'
          balias gma='git merge --abort'

          balias gnd='git clone'

          # Select which folders called target/ inside ~/src to delete
          balias delete-targets="fd -It d '^target$' ~/src | fzf --multi --preview='exa -al {}/..' | xargs rm -r"

          # Select git branches to delete
          balias delete-branches="git branch | rg -v '\*' | cut -c 3- | fzf --multi --preview='git hist {}' | xargs git branch --delete --force"
        '';
      in
      {
        enable = true;
        enableCompletion = true;
        enableAutosuggestions = true;
        dotDir = ".config/zsh";
        defaultKeymap = "viins";

        initExtra = ''
          ${functions}
          ${aliases}

          unset RPS1

          bindkey "^?" backward-delete-char
          bindkey "^W" backward-kill-word
          bindkey "^H" backward-delete-char
          bindkey "^U" backward-kill-line

          # Ignore files matching the pattern *.lock when completing arguments to the `nvim`, `vim` 
          # or `vi` commands.
          zstyle ':completion:*:*:nvim:*' file-patterns '^*.lock:source-files' '*:all-files'
          zstyle ':completion:*:*:vim:*' file-patterns '^*.lock:source-files' '*:all-files'
          zstyle ':completion:*:*:vi:*' file-patterns '^*.lock:source-files' '*:all-files'

          # If zsh is started with NOHISTFILE set, disable history
          if [ ! -z $NOHISTFILE ] && $NOHISTFILE; then
            unset HISTFILE
          fi

          # Remove / and = from $WORDCHARS so that ctrl-w stops at them
          WORDCHARS=''${WORDCHARS//[\/=]}
        '';

        plugins = with pkgs; [
          (mkZshPlugin { pkg = zsh-syntax-highlighting; })
        ];
      };
  };
}

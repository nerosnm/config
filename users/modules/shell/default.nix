{ self
, config
, lib
, pkgs
, ...
}:

let
  fuzz =
    let
      fd = "${pkgs.fd}/bin/fd";
    in
    rec {
      defaultCommand = "${fd} -H --type f";
      defaultOptions = [ "--height 50%" "--border" ];
      fileWidgetCommand = "${defaultCommand}";
      fileWidgetOptions = [
        "--preview '${pkgs.bat}/bin/bat --color=always --plain --line-range=:200 {}'"
      ];
      changeDirWidgetCommand = "${fd} --type d";
      changeDirWidgetOptions =
        [ "--preview '${pkgs.tree}/bin/tree -C {} | head -200'" ];
    };

  aliases = {
    # Aliases that are not expanded
  };

  functionsFile = builtins.readFile ./functions.sh;
  aliasesFile = builtins.readFile ./aliases.sh;
in
{
  home.sessionVariables = {
    CLICOLOR = 1;
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
    DEFAULT_USER = "${config.home.username}";
    LANG = "en_GB.UTF-8";
    LESS = "R";
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=240";
  };

  programs = {
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

    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    } // fuzz;

    zsh =
      let
        mkZshPlugin = { pkg, file ? "${pkg.pname}.plugin.zsh" }: rec {
          name = pkg.pname;
          src = pkg.src;
          inherit file;
        };
      in
      {
        enable = true;
        enableCompletion = true;
        enableAutosuggestions = true;
        dotDir = ".config/zsh";
        defaultKeymap = "viins";

        shellAliases = aliases;

        initExtra = ''
          ${functionsFile}
          ${aliasesFile}

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

    zoxide.enable = true;
    starship.enable = true;
  };
}

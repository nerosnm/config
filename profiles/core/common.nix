{ self, config, lib, pkgs, ... }:

let
  inherit (lib) fileContents;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  # Sets the nix community binary cache which just speeds up some builds
  imports = [ ../cachix ];

  environment = {
    # Selection of sysadmin tools that can come in handy
    systemPackages = with pkgs; [
      asciiquarium
      bat
      binutils
      bottom
      btop
      coreutils
      curl
      dconf2nix
      dig
      direnv
      dnsutils
      exa
      fd
      fzf
      git
      glow
      hyperfine
      inetutils
      jq
      keybase
      lsof
      manix
      moreutils
      nix-index
      nmap
      ripgrep
      sd
      skim
      tealdeer
      tokei
      unzip
      wget
      whois
      xclip
      xsel
      youtube-dl
      zip
    ];

    variables = {
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
    };

    etc."gitignore".source = ./gitignore;

    # Starship is a fast and featureful shell prompt
    # starship.toml has sane defaults that can be changed there
    shellInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml"
        (fileContents ./starship.toml)
      }

      ulimit -n 4096
    '';

    shellAliases =
      let
        # The `security.sudo.enable` option does not exist on darwin because
        # sudo is always available.
        ifSudo = lib.mkIf (isDarwin || config.security.sudo.enable);
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # grep
        grep = "rg";
        gi = "grep -i";

        # internet ip
        # TODO: explain this hard-coded IP address
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        np = "n profile";
        ni = "np install";
        nr = "np remove";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        nepl = "n repl '<nixpkgs>'";
        srch = "ns nixos";
        orch = "ns override";
        mn = ''
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
        '';
        top = "btm";

        # sudo
        s = ifSudo "sudo -E ";
        si = ifSudo "sudo -i";
        se = ifSudo "sudoedit";
      };
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  fonts.fonts = with pkgs; [
    iosevka-custom
  ];

  nix = {
    settings = {
      # Prevents impurities in builds
      sandbox = true;

      # Give root user and wheel group special Nix privileges.
      trusted-users = [ "root" "@wheel" ];
    };

    # Improve nix store disk usage
    gc.automatic = true;

    # Generally useful nix option defaults
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };
}

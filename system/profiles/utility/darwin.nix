{ pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  homebrew = {
    casks = [
      "1password"
      "contexts"
      "elgato-stream-deck"
      "firefox-developer-edition"
      "gnucash"
      "lagrange"
      "linear-linear"
      "monodraw"
      "mpv"
      "nordvpn"
      "radio-silence"
      "scroll-reverser"
      "spotify"
      "tidal"
      "wezterm"
    ];

    masApps = {
      "Tailscale" = 1475387142;
      "Spotica Menu" = 570549457;
    };
  };

  programs.zsh.interactiveShellInit = ''
    source /Applications/WezTerm.app/Contents/Resources/wezterm.sh
    export TERM=wezterm
  '';
}

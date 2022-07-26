{ self
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  homebrew.casks = [
    "1password"
    "contexts"
    "firefox-developer-edition"
    "gnucash"
    "lagrange"
    "mpv"
    "nordvpn"
    "radio-silence"
    "spotify"
    "transmission"
    "wezterm"
  ];
}

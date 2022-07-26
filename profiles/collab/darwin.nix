{ self
, pkgs
, ...
}:

{
  homebrew.casks = [
    "slack"
    "thunderbird"
    "zoom"
    "zulip"
  ];
}

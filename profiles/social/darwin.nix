{ self
, pkgs
, ...
}:

{
  homebrew.casks = [
    "discord"
    "discord-ptb"
    "signal"
    "thunderbird"
    "zulip"
  ];
}

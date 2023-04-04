{ pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    catgirl
  ];

  homebrew.casks = [
    "discord"
    "discord-ptb"
    "signal"
    "zulip"
  ];
}

{ self
, pkgs
, ...
}:

{
  # Not all of these are strictly "social", but the distinction here is that 
  # these are communication apps that are used at least partly for personal 
  # communication. This is opposed to the apps in the `collab` profile, which 
  # are communication apps used at least partly for work communication.
  environment.systemPackages = with pkgs; [
    discord-linux
    discord-ptb-linux
    signal-desktop
    tiny
    thunderbird
    zulip
  ];
}

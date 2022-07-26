{ self
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    slack
    thunderbird
    zoom-us
    zulip
  ];
}

{ pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    notion-app-enhanced
    obs-studio
    slack
    thunderbird
    zoom-us
    zulip
  ];
}

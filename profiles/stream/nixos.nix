{ self
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    obs-studio
  ];
}

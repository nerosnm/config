{ config
, lib
, pkgs
, self
, ...
}:

{
  environment.systemPackages = with pkgs; [
    yubikey-manager # To customise Yubikey options
    yubikey-personalization # Also to customise Yubikey options
  ];
}

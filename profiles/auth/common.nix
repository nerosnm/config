{ config
, lib
, pkgs
, self
, ...
}:

{
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-manager # To customise Yubikey options
    yubikey-personalization # Also to customise Yubikey options
  ];
}

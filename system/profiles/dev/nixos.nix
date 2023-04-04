{ config
, pkgs
, ...
}:

# Development-specific packages and configuration.

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    insomnia
    jetbrains.clion
    jetbrains.idea-community
    jetbrains.idea-ultimate
    libresprite
  ];
}

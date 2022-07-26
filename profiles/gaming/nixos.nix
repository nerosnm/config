{ config
, lib
, pkgs
, self
, ...
}:

{
  environment.systemPackages = with pkgs; [
    # Minecraft
    glibc
    jdk
    jdk8
    minecraft
    polymc

    # Lutris
    lutris

    # Veloren
    airshipper
  ];

  programs.steam.enable = true;
}

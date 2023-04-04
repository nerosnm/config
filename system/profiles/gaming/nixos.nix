{ config
, lib
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    # Minecraft
    glibc
    jdk
    jdk8
    minecraft
    prismlauncher

    # Lutris
    lutris

    # Veloren
    airshipper
  ];

  programs.steam.enable = true;
}

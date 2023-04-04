{ config
, lib
, pkgs
, ...
}:

{
  homebrew.casks = [
    # Minecraft
    "prismlauncher"

    # Steam
    "steam"
  ];
}

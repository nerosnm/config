{ config
, lib
, pkgs
, self
, ...
}:

{
  homebrew.casks = [
    # Minecraft
    "multimc"
    "adoptopenjdk8"

    # Steam
    "steam"
  ];
}

{ config
, pkgs
, ...
}:

# Development-specific packages and configuration.

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    tailscale
  ];

  homebrew = {
    casks = [
      "docker"
      "insomnia"
    ];

    masApps = {
      "Tailscale" = 1475387142;
      "Xcode" = 497799835;
    };
  };
}

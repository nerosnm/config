{ config
, pkgs
, ...
}:

# Development-specific packages and configuration.

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    # ninja
    # swig
    tailscale
  ];

  environment.systemPath = [
    "/opt/fleet"
  ];

  homebrew = {
    brews = [
      # "ios-deploy"
      # "libimobiledevice"
      # "swiftlint"
    ];

    casks = [
      # "cool-retro-term"
      "docker"
      # "insomnia"
      "jetbrains-toolbox"
      "tla-plus-toolbox"
    ];

    masApps = {
      "Tailscale" = 1475387142;
      "Xcode" = 497799835;
    };
  };
}

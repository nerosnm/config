{ lib, ... }: {
  homebrew.casks = [
    # This really does have to be installed through Homebrew, or 1Password will refuse to integrate
    # with it.
    "firefox"

    "skim"
    "zulip"
  ];

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
    };
  };

  services = {
    yknotify-rs = {
      enable = true;
      requestSound = "Funk";
      dismissedSound = "Hero";
    };
  };

  system.stateVersion = 6;
  system.primaryUser = lib.mkForce "madeleine.mortensen";
}

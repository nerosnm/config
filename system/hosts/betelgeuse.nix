{ pkgs, ... }: {
  imports = [
    ../non-work.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      mpv
    ];
  };

  homebrew.casks = [
    # This really does have to be installed through Homebrew, or 1Password will refuse to integrate
    # with it.
    "firefox"

    "ableton-live-standard"
    "adobe-acrobat-reader"
    "handbrake-app"
    "obs"
    "radio-silence"
    "skim"
    "splice"
    "steam"
    "teamspeak-client"
    "transmission"
    "vivid-app"
  ];

  system.stateVersion = 5;
}

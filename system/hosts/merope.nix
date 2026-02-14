{ ... }: {
  imports = [
    ../non-work.nix
  ];

  homebrew.casks = [
    # This really does have to be installed through Homebrew, or 1Password will refuse to integrate
    # with it.
    "firefox"

    # "ableton-live-standard"
    # "adobe-acrobat-reader"
    # "ungoogled-chromium"
    # "handbrake-app"
    # "obs"
    # "radio-silence"
    # "skim"
    # "splice"
    # "steam"
    # "teamspeak-client"
    # "transmission"
  ];

  system.stateVersion = 6;
}

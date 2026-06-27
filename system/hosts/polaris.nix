{
  pkgs,
  pkgsUnstable,
  ...
}:
{
  imports = [
    ../non-work.nix
  ];

  environment = {
    systemPackages =
      (with pkgs; [
        # jdk17
        jdk21
        pandoc
        postgresql_15
      ])
      ++ (with pkgsUnstable; [
        ffmpeg
      ]);

    variables = {
      JRE8 = "${pkgs.jre8}";
    };
  };

  homebrew = {
    brews = [
      "yt-dlp"
    ];

    casks = [
      # This really does have to be installed through Homebrew, or 1Password will refuse to
      # integrate with it.
      "firefox@developer-edition"

      "ableton-live-standard"
      "adobe-acrobat-reader"
      "blockbench"
      "ungoogled-chromium"
      "handbrake-app"
      "insomnia"
      "jetbrains-toolbox"
      "jubler"
      "lagrange"
      "mkvtoolnix-app"
      "obs"
      "prismlauncher"
      "radio-silence"
      "skim"
      "splice"
      "steam"
      "stolendata-mpv"
      "subler"
      "teamspeak-client"
      "transmission"
      "zoom"
    ];
  };

  services = {
    yknotify-rs = {
      enable = true;
      requestSound = "Funk";
      dismissedSound = "Hero";
    };
  };

  system.stateVersion = 5;
}

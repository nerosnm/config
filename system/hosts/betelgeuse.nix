{ pkgs
, pkgsUnstable
, ...
}:

{
  environment = {
    systemPackages = (with pkgs; [
      jdk17
      pandoc
      python39Packages.pygments
    ]) ++ (with pkgsUnstable; [
      catgirl
      tectonic
      typst
    ]);

    variables = {
      JRE8 = "${pkgs.jre8}";
    };
  };

  homebrew = {
    casks = [
      "ableton-live-standard"
      "calibre"
      "chromium"
      "discord@ptb"
      "gnucash"
      "handbrake"
      "jetbrains-toolbox"
      "lagrange"
      "obs"
      "prismlauncher"
      "skim"
      "splice"
      "steam"
      "stolendata-mpv"
      "teamspeak-client"
      "transmission"
      "zulip"
    ];
  };

  system.stateVersion = 5;
}
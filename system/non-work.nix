{ pkgsUnstable, ... }: {
  environment.systemPackages = with pkgsUnstable; [
    spotify
    tailscale-gui
  ];

  homebrew = {
    brews = [
      "xcode-build-server" # For xcodebuild.nvim
    ];
    casks = [
      "alt-tab"
      "calibre"
      "discord"
      "linear"
      # "logi-options+"
      "mullvad-vpn"
      "signal"
      "ungoogled-chromium"
      "whatsapp"
      "zulip"
    ];
  };

  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      blockAllIncoming = false;

      # Allow any downloaded app that's been signed to accept incoming requests.
      allowSignedApp = true;
    };
  };
}

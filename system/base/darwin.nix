{ config
, lib
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment = {
    # Starship is a fast and featureful shell prompt
    # starship.toml has sane defaults that can be changed there
    extraInit = ''
      export STARSHIP_CONFIG=${
        pkgs.writeText "starship.toml"
        (lib.fileContents ../../static/starship.toml)
      }
      ulimit -n unlimited
    '';

    pathsToLink = [
      "/Applications"
    ];

    systemPath = [
      "/opt/homebrew/bin"
    ];
  };

  nix = {
    nixPath = [
      # TODO: This entry should be added automatically via FUP's
      # `nix.linkInputs` and `nix.generateNixPathFromInputs` options, but
      # currently that doesn't work because nix-darwin doesn't export packages,
      # which FUP expects.
      #
      # This entry should be removed once the upstream issues are fixed.
      #
      # https://github.com/LnL7/nix-darwin/issues/277
      # https://github.com/gytis-ivaskevicius/flake-utils-plus/issues/107
      #
      # NOTE: FUP isn't being used in this flake anymore......
      "darwin=/etc/nix/inputs/darwin"
    ];

    # Auto manage nixbld users with nix darwin.
    configureBuildUsers = true;

    settings = {
      # Administrative users on Darwin are part of the @admin group.
      trusted-users = [ "@admin" ];
    };
  };

  homebrew = {
    enable = true;

    global.brewfile = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;

    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
    ];
  };

  services = {
    nix-daemon.enable = true;

    # Recreate /run/current-system symlink after boot
    activate-system.enable = true;
  };

  fonts.fontDir.enable = true;

  programs.bash = {
    # nix-darwin's shell options are very different from those on nixos. there
    # is no `promptInit` option, for example. so instead, we throw the prompt
    # init line into `interactiveShellInit`.
    #
    # https://github.com/LnL7/nix-darwin/blob/master/modules/programs/bash/default.nix
    interactiveShellInit = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };

  programs.zsh = {
    # Resolve a collision
    enableCompletion = false;

    interactiveShellInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
  };

  system = {
    defaults = {
      LaunchServices = {
        # Disable quarantine for downloaded applications.
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        # Turn off "font smoothing", because it looks terrible on HiDPI displays that aren't Retina.
        AppleFontSmoothing = 0;

        # Allow Tab to control all UI elements.
        AppleKeyboardUIMode = 3;

        # Disable press-and-hold for entering special characters.
        ApplePressAndHoldEnabled = false;

        # Hide scrollbars except when actively scrolling, regardless of input device.
        AppleShowScrollBars = "WhenScrolling";

        # Turn off all the automatic correction shit.
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        # Don't save things to iCloud automatically.
        NSDocumentSaveNewDocumentsToCloud = false;

        # Use the expanded save dialog by default. Why are there two??
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Use medium size Finder sidebar icons.
        NSTableViewDefaultSizeMode = 2;

        # The amount of time after starting to hold down a key that it begins to repeat.
        InitialKeyRepeat = 10;
        # The amount of time betweeen repeated keypresses when holding a key.
        KeyRepeat = 2;
      };

      SoftwareUpdate = {
        # Don't automatically install macOS software updates.
        AutomaticallyInstallMacOSUpdates = false;
      };

      # Firewall settings.
      alf = {
        # Enable the firewall.
        globalstate = 1;

        # Allow any downloaded app that's been signed to accept incoming requests.
        allowdownloadsignedenabled = 1;

        # Enable stealth mode (drops incoming requests via ICMP such as ping requests).
        stealthenabled = 1;
      };

      dock = {
        # Auto-hide the dock.
        autohide = true;

        # Don't show recent apps in the dock.
        show-recents = false;

        # Don't only show open apps in the dock.
        static-only = false;

        # Set the icon size in the dock to smaller than default.
        tilesize = 50;
      };

      finder = {
        # Don't show icons on the desktop.
        CreateDesktop = false;

        # Don't warn when changing the extension of items.
        FXEnableExtensionChangeWarning = false;
      };

      loginwindow = {
        # Show the login window as a name and password field instead of a list of users.
        SHOWFULLNAME = true;

        # Disable guest login.
        GuestEnabled = false;
      };

      screencapture = {
        location = "~/Pictures/Screenshots";
      };

      trackpad = {
        # Enable tap-to-click on the trackpad.
        Clicking = true;
      };
    };

    # keyboard.enableKeyMapping = true;
    # keyboard.remapCapsLockToControl = true;
  };
}

{ config
, lib
, ...
}:

with lib;
let
  cfg = config.custom.dconf;
  inherit (lib.hm.gvariant) mkTuple mkUint32;
in
{
  options.custom.dconf = with types; {
    enable = mkEnableOption "dconf setting overrides";

    background = mkOption {
      description = "Path to a desktop background image";
      type = nullOr path;
      default = null;
    };

    xkbSources = mkOption {
      description = "List of xkb input sources to use";
      type = listOf string;
      default = [ "gb" ];
    };

    nightLight = mkEnableOption "Night Light";
  };

  config = mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/clocks" = {
        world-clocks = "[{'location': <(uint32 2, <('San Francisco', 'KOAK', true, [(0.65832848982162007, -2.133408063190589)], [(0.659296885757089, -2.1366218601153339)])>)>}]";
      };

      "org/gnome/control-center" = {
        # This was always huge for some reason. Make it smaller.
        window-state = mkTuple [ 1198 867 ];
      };

      "org/gnome/desktop/background" = mkIf (cfg.background != null) {
        # Set the desktop background statically to this image.
        picture-uri = "${cfg.background}";
      };

      "org/gnome/desktop/input-sources" = {
        # Different windows do not have independent input source settings.
        per-window = false;
        # Turn each xkb source into a tuple ("xkb", source).
        sources = map (source: mkTuple [ "xkb" source ]) cfg.xkbSources;
        xkb-options = [
          # Switch input sources with alt-space.
          "grp:alt_space_toggle"
          # Use left alt as the alternate characters key.
          # "lv3:lalt_switch"
          # Use right alt as the compose key.
          "compose:ralt"
        ];
      };

      "org/gnome/desktop/interface" = {
        # Disable hot corners.
        enable-hot-corners = false;
        # Not sure!
        toolkit-accessibility = false;
      };

      "org/gnome/desktop/peripherals/mouse" = {
        speed = -0.25;
      };

      "org/gnome/desktop/session" = {
        # Set the screen blank delay to 15 minutes.
        idle-delay = mkUint32 900;
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-5 = [ "<Super>5" ];
        switch-to-workspace-6 = [ "<Super>6" ];
        switch-to-workspace-7 = [ "<Super>7" ];
        switch-to-workspace-8 = [ "<Super>8" ];
        switch-to-workspace-9 = [ "<Super>9" ];
        switch-to-workspace-10 = [ "<Super>0" ];

        move-to-workspace-1 = [ "<Shift><Super>exclam" ];
        move-to-workspace-2 = [ "<Shift><Super>quotedbl" ];
        move-to-workspace-3 = [ "<Shift><Super>sterling" ];
        move-to-workspace-4 = [ "<Shift><Super>dollar" ];
        move-to-workspace-5 = [ "<Shift><Super>percent" ];

        switch-input-source = [ "<Alt>space" ];
        switch-input-source-backward = [ "<Shift><Alt>space" ];

        switch-windows = [ "<Super>Tab" ];
        switch-windows-backward = [ "<Shift><Super>Tab" ];

        close = [ "<Super>q" ];

        # Clear a bunch of defaults that I don't want.
        activate-window-menu = [ ];
        begin-move = [ ];
        begin-resize = [ ];
        cycle-group = [ ];
        cycle-group-backward = [ ];
        cycle-panels = [ ];
        cycle-panels-backward = [ ];
        cycle-windows = [ ];
        cycle-windows-backward = [ ];
        minimize = [ ];
        move-to-monitor-down = [ ];
        move-to-monitor-left = [ ];
        move-to-monitor-right = [ ];
        move-to-monitor-up = [ ];
        move-to-workspace-last = [ ];
        move-to-workspace-left = [ ];
        move-to-workspace-right = [ ];
        switch-applications = [ ];
        switch-applications-backward = [ ];
        switch-group = [ ];
        switch-group-backward = [ ];
        switch-panels = [ ];
        switch-panels-backward = [ ];
        switch-to-workspace-last = [ ];
        switch-to-workspace-left = [ ];
        switch-to-workspace-right = [ ];
        toggle-maximized = [ ];
      };

      "org/gnome/desktop/wm/preferences" = {
        # I want 5 workspaces...
        num-workspaces = 5;
        # ...and these are their names.
        workspace-names = [ "General" "Communication" "Eeby" "Deeby" "Music" ];
      };

      "org/gnome/evolution-data-server/calendar" = {
        # Clear this stupid list that breaks dconf2nix parsing
        reminders-past = [ ];
      };

      "org/gnome/mutter" = {
        attach-modal-dialogs = true;
        dynamic-workspaces = false;
        edge-tiling = true;
        focus-change-on-pointer-rest = true;
        overlay-key = "";
        workspaces-only-on-primary = true;
      };

      "org/gnome/mutter/wayland/keybindings" = {
        # Clear another default keybinding.
        restore-shortcuts = [ ];
      };

      "org/gnome/nautilus/preferences" = {
        # Use list view in the file viewer.
        default-folder-viewer = "list-view";
      };

      "org/gnome/settings-daemon/plugins/color" = {
        # Turn on Night Light.
        night-light-enabled = cfg.nightLight;
        # Set the colour temperature to the first tick from the left.
        night-light-temperature = mkUint32 3700;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        # Link to the two custom keybindings below.
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];

        # I don't know why locking the screen is a media key.
        screensaver = [ "<Shift><Super>l" ];

        # Clear more default keybindings.
        help = [ ];
        home = [ ];
        logout = [ ];
        magnifier = [ ];
        magnifier-zoom-in = [ ];
        magnifier-zoom-out = [ ];
        screenreader = [ ];
      };

      # Custom keybinding for a mute key for Discord, set here to keep it from 
      # conflicting with anything else or being swallowed.
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Shift><Super>m";
        command = "true";
        name = "Mute Discord";
      };

      # Same for a deafen key.
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Shift><Super>d";
        command = "true";
        name = "Deafen Discord";
      };

      "org/gnome/settings-daemon/plugins/power" = {
        # Suspend if the power button is pressed, instead of fucking turning off.
        power-button-action = "suspend";

        # Don't automatically suspend.
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/shell/extensions/sp-tray" = {
        # Hide the Spotify extension whenever Spotify is closed or not playing.
        hidden-when-inactive = true;
        hidden-when-paused = true;
      };

      "org/gnome/shell/keybindings" = {
        # Toggle the overview with Super-Space rather than just Super.
        toggle-overview = [ "<Super>space" ];

        # Take a screenshot.
        show-screenshot-ui = [ "Print" ];

        # Clear even more default keybindings.
        focus-active-notification = [ ];
        screenshot = [ ];
        screenshot-window = [ ];
        show-screen-recording-ui = [ ];
        switch-to-application-1 = [ ];
        switch-to-application-10 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
        switch-to-application-5 = [ ];
        switch-to-application-6 = [ ];
        switch-to-application-7 = [ ];
        switch-to-application-8 = [ ];
        switch-to-application-9 = [ ];
        toggle-message-tray = [ ];
      };

      "org/gnome/shell/weather" = {
        # Use automatic location for the weather.
        automatic-location = true;
      };

      "org/gnome/system/location" = {
        # Enable location services.
        enabled = true;
      };

      "org/gtk/settings/file-chooser" = {
        # Show hidden files in Nautilus.
        show-hidden = true;
      };
    };
  };
}

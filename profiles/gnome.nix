{ config
, lib
, pkgs
, ...
}:

{
  programs.dconf.enable = true;

  services = {
    xserver = {
      enable = true;

      desktopManager.gnome.enable = true;

      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };

    udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  };

  environment.systemPackages = with pkgs;
    let
      spotify-tray = gnomeExtensions.buildShellExtension {
        uuid = "sp-tray@sp-tray.esenliyim.github.com";
        name = "spotify-tray";
        pname = "spotify-tray";
        description = ''
          Adds a button to the panel that shows information Spotify playback. For
          bug reports, feature requests, translation contributions, etc., please
          visit the extension's github page.
        '';
        link = "https://extensions.gnome.org/extension/4472/spotify-tray/";
        version = 19;
        sha256 = "sha256-J0zYv1qfuAmUalABfuSryEnX0aaoiET2KlTP4tpE8bU=";
        metadata = ''
          ewogICAgImRlc2NyaXB0aW9uIjogIkFkZHMgYSBidXR0b24gdG8gdGhlIHBhbmVsIHRoYXQgc2hv
          d3MgaW5mb3JtYXRpb24gU3BvdGlmeSBwbGF5YmFjay4gRm9yIGJ1ZyByZXBvcnRzLCBmZWF0dXJl
          IHJlcXVlc3RzLCB0cmFuc2xhdGlvbiBjb250cmlidXRpb25zLCBldGMuLCBwbGVhc2UgdmlzaXQg
          dGhlIGV4dGVuc2lvbidzIGdpdGh1YiBwYWdlLiIsCiAgICAibmFtZSI6ICJzcG90aWZ5LXRyYXki
          LAogICAgInNoZWxsLXZlcnNpb24iOiBbCiAgICAgICAgIjQwIiwKICAgICAgICAiNDEiLAogICAg
          ICAgICI0MiIsCiAgICAgICAgIjQzIgogICAgXSwKICAgICJ1cmwiOiAiaHR0cHM6Ly9naXRodWIu
          Y29tL2VzZW5saXlpbS9zcC10cmF5IiwKICAgICJ1dWlkIjogInNwLXRyYXlAc3AtdHJheS5lc2Vu
          bGl5aW0uZ2l0aHViLmNvbSIsCiAgICAidmVyc2lvbiI6IDE5LAogICAgInNldHRpbmdzLXNjaGVt
          YSI6ICJvcmcuZ25vbWUuc2hlbGwuZXh0ZW5zaW9ucy5zcC10cmF5Igp9Cg==
        '';
      };
    in
    [
      gnome.gnome-tweaks
      gnomeExtensions.sound-output-device-chooser
      spotify-tray
    ];
}

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

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.spotify-tray
  ];
}

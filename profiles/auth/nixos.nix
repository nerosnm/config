{ config
, lib
, pkgs
, self
, ...
}:

{
  imports = [
    ./common.nix
  ];

  environment.systemPackages = with pkgs; [
    yubikey-manager-qt # To customise Yubikey options
  ];

  # Enable pcscd for communication with the Yubikey
  services.pcscd.enable = true;

  # Add a udev rule to allow yubikey-personalization to communicate with the Yubikey
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  programs.ssh = {
    extraConfig = ''
      Host *
        IdentitiesOnly yes
        PreferredAuthentications publickey
        ServerAliveInterval 15
    '';
  };

  services.keybase.enable = true;

  systemd.user.services.yubikey-touch-detector = {
    enable = true;

    description = ''
      Detects when your YubiKey is waiting for a touch
    '';

    wantedBy = [ "default.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      ${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector -libnotify
    '';
  };
}

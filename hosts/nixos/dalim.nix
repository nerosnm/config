{ self
, profiles
, suites
, ...
}:

{
  imports = suites.work ++ (with profiles; [
    moonlander.nixos
    printing.nixos
  ]);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };
}

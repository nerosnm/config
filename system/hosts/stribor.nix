{ config
, lib
, modulesPath
, pkgs
, ...
}:

let
  deploy = builtins.readFile ../../keys/stribor-deploy.pub;
  soren = builtins.readFile ../../keys/soren.pub;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking = {
    hostName = "stribor";
    domain = "";

    firewall = {
      enable = true;

      checkReversePath = "loose";

      # Expose the SSH port to the public internet
      allowedTCPPorts = [ 22 ];
    };
  };

  # Enable the OpenSSH server and allow both keys to authenticate with `root`.
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = [ deploy soren ];

  time.timeZone = "Europe/London";

  boot = {
    cleanTmpDir = true;
    loader.grub.device = "/dev/sda";
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
      kernelModules = [ "nvme" ];
    };
  };

  zramSwap.enable = true;

  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  system.stateVersion = "22.11";

  programs.zsh = {
    enable = true;
    # Enable starship
    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
  };
  users.defaultUserShell = pkgs.zsh;

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://nerosnm.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nerosnm.cachix.org-1:y72US4O6QNV8WoofFIOKRL1fnvzd/8IY4OO9a7K4bV8="
      ];
    };

    # Improve nix store disk usage
    gc.automatic = true;
  };

  # Acme
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "soren@neros.dev";
      webroot = "/var/lib/acme/acme-challenge";
    };
  };

  # Tailscale
  age.secrets."tailscale-stribor" = {
    file = ../../secrets/tailscale-stribor.age;
    owner = "root";
    group = "root";
  };

  nerosnm.services.tailscale = {
    enable = true;
    trustInterface = true;
    authKey = "file:" + "${config.age.secrets."tailscale-stribor".path}";
  };

  nerosnm.services.prometheus.nodeExporter.enable = true;

  # nerosnm.services.ll5 = {
  #   enable = true;
  #   memory = 4916;
  # };
}

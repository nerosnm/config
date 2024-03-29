{ config
, modulesPath
, pkgs
, ...
}:

let
  deploy = builtins.readFile ../../keys/atria-deploy.pub;
  soren = builtins.readFile ../../keys/soren.pub;
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ../profiles/gemmat-dev-redirect.nix
  ];

  networking = {
    hostName = "atria";

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

  # Reject HTTP requests to the root
  services.nginx = {
    enable = true;
    virtualHosts = {
      "\"\"" = {
        default = true;
        rejectSSL = true;
        locations."/" = {
          return = "418";
        };
      };
    };
  };

  time.timeZone = "Europe/London";

  boot = {
    cleanTmpDir = true;
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };

    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    initrd.kernelModules = [ "nvme" ];
  };

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
  age.secrets."tailscale-atria" = {
    file = ../../secrets/tailscale-atria.age;
    owner = "root";
    group = "root";
  };

  nerosnm.services.tailscale = {
    enable = true;
    trustInterface = true;
    authKey = "file:" + "${config.age.secrets."tailscale-atria".path}";
  };

  # Grafana
  age.secrets."grafana-admin-password" = {
    file = ../../secrets/grafana-admin-password.age;
    owner = "grafana";
    group = "grafana";
  };

  age.secrets."tailscale-grafana" = {
    file = ../../secrets/tailscale-grafana.age;
    owner = "proxy-to-grafana";
    group = "proxy-to-grafana";
  };

  nerosnm.services.grafana = {
    enable = true;
    tailscaleDomain = "penguin-bramble.ts.net";

    secrets = {
      adminPassword = "grafana-admin-password";
      tailscaleAuthkey = "tailscale-grafana";
    };
  };

  nerosnm.services.prometheus.nodeExporter.enable = true;

  nerosnm.services.neros-dev = {
    enable = true;
    secrets = { };

    loki.host = "localhost";
    loki.port = 9003;

    tempo.host = "localhost";
    tempo.port = 4317;
  };

  nerosnm.services.cacti-dev.enable = true;

  age.secrets."hatysa-discord-token" = {
    file = ../../secrets/hatysa-discord-token.age;
    owner = "hatysa";
    group = "hatysa";
  };
  nerosnm.services.hatysa = {
    enable = true;
    secrets.discordToken = "hatysa-discord-token";
  };

  age.secrets."pomocop-discord-token" = {
    file = ../../secrets/pomocop-discord-token.age;
    owner = "pomocop";
    group = "pomocop";
  };
  age.secrets."pomocop-application-id" = {
    file = ../../secrets/pomocop-application-id.age;
    owner = "pomocop";
    group = "pomocop";
  };
  age.secrets."pomocop-owner-id" = {
    file = ../../secrets/pomocop-owner-id.age;
    owner = "pomocop";
    group = "pomocop";
  };
  nerosnm.services.pomocop = {
    enable = true;
    secrets = {
      token = "pomocop-discord-token";
      applicationId = "pomocop-application-id";
      ownerId = "pomocop-owner-id";
    };
  };

  age.secrets."oxbow-client-id" = {
    file = ../../secrets/oxbow-client-id.age;
    owner = "oxbow";
    group = "oxbow";
  };
  age.secrets."oxbow-client-secret" = {
    file = ../../secrets/oxbow-client-secret.age;
    owner = "oxbow";
    group = "oxbow";
  };
  nerosnm.services.oxbow = {
    enable = true;
    secrets = {
      clientId = "oxbow-client-id";
      clientSecret = "oxbow-client-secret";
    };
  };
}

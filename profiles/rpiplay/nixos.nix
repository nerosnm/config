{ self
, config
, pkgs
, ...
}:

{
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    7000
    7100
  ];
  networking.firewall.allowedUDPPorts = [
    7011
  ];

  systemd.user.services.rpiplay = {
    enable = true;

    wantedBy = [ ];
    after = [ "network.target" ];
    wants = [ "network.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      ${pkgs.rpiplay}/bin/rpiplay -n ${config.networking.hostName} -l
    '';
  };
}

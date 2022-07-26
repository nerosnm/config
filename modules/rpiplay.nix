{ self
, config
, lib
, pkgs
, ...
}:

let
  cfg = config.services.rpiplay;

  inherit (lib) mkIf;
in
{
  options.services.rpiplay = with lib; {
    enable = mkEnableOption "rpiplay service";
  };

  config = mkIf cfg.enable {
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

      wantedBy = [ "default.target" ];
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
  };
}

{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.cacti-dev;

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.cacti-dev = {
      enable = mkEnableOption "Activate the various webpages hosted under cacti.dev";
    };
  };

  config = mkIf cfg.enable {
    # Expose the HTTP and HTTPS ports to the public internet
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nginx = {
      enable = true;

      virtualHosts = {
        "cacti.dev" = {
          enableACME = true;
          forceSSL = true;

          locations."/" = {
            root = pkgs.cacti-dev.out;
          };
        };

        "oxbow.cacti.dev" = {
          forceSSL = true;
          useACMEHost = "cacti.dev";

          locations."/" = {
            root = pkgs.oxbow-cacti-dev.out;
          };
        };
      };
    };

    security.acme.certs."cacti.dev".extraDomainNames = [
      "oxbow.cacti.dev"
    ];
  };
}

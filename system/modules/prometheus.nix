{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.prometheus;
  home = "/srv/prometheus";

  inherit (lib) optionals;
in
{
  options = with lib; {
    nerosnm.services.prometheus = {
      enable = mkEnableOption "Prometheus";

      port = mkOption rec {
        description = ''
          Port to serve Prometheus over.
        '';
        type = types.int;
        default = 9001;
        example = default;
      };

      nodeExporter = {
        enable = mkEnableOption "Prometheus node exporter";

        port = mkOption rec {
          description = ''
            Port to serve the Prometheus node exporter over.
          '';
          type = types.int;
          default = 9002;
          example = default;
        };
      };
    };
  };

  config = {
    services.prometheus = {
      inherit (cfg) enable port;

      exporters = {
        node = {
          inherit (cfg.nodeExporter) enable port;
          enabledCollectors = [ "systemd" ];
        };
      };

      globalConfig = {
        scrape_interval = "5s";
      };

      scrapeConfigs = [
      ] ++ optionals cfg.enable [
        {
          job_name = "node";
          static_configs = map
            (hostname: {
              targets = [ "${hostname}:${toString cfg.nodeExporter.port}" ];
              labels.host = hostname;
            })
            [
              "atria"
              "ll5"
              "pincoya"
              "taygeta"
            ];
        }
      ];
    };
  };
}

{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.grafana;
  promcfg = config.nerosnm.services.prometheus;
  lokicfg = config.nerosnm.services.loki;
  tempocfg = config.nerosnm.services.tempo;

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.grafana = {
      enable = mkEnableOption "Grafana";

      port = mkOption rec {
        description = ''
          Port to serve Grafana interface over.
        '';
        type = types.int;
        default = 2342;
        example = default;
      };

      hostname = mkOption rec {
        description = ''
          Hostname to use for the grafana service within your tailnet.
        '';
        type = types.str;
        default = "grafana";
        example = "dashboards";
      };

      tailscaleDomain = mkOption rec {
        description = ''
          Tailscale domain for your tailnet
        '';
        type = types.str;
        example = "your-tailscale-https-domain.ts.net";
      };

      secrets = mkOption {
        description = "Names of secrets for use in this module";

        type = types.submodule {
          options = {
            adminPassword = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Grafana admin
                password. The owner and group should both be "grafana".
              '';
              type = types.str;
              example = "grafana-admin-password";
            };

            tailscaleAuthkey = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Tailscale authkey
                for proxy-to-grafana. The owner and group should both be
                "grafana-proxy".
              '';
              type = types.str;
              example = "proxy-to-grafana-hostname";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    nerosnm.services.prometheus.enable = cfg.enable;
    nerosnm.services.loki.enable = cfg.enable;
    nerosnm.services.tempo.enable = cfg.enable;

    services.grafana = {
      inherit (cfg) enable;

      dataDir = "/srv/grafana";

      settings = {
        server = {
          domain = "${cfg.hostname}.${cfg.tailscaleDomain}";
          root_url = "https://${cfg.hostname}.${cfg.tailscaleDomain}";
          http_addr = "127.0.0.1";
          http_port = cfg.port;
        };

        security = {
          admin_password = "$__file{${config.age.secrets."${cfg.secrets.adminPassword}".path}}";
        };

        "auth.proxy" = {
          enabled = true;
          header_name = "X-WebAuth-User";
          header_property = "username";
          auto_sign_up = true;
          sync_ttl = 60;
          whitelist = "127.0.0.1";
          headers = "Name:X-WebAuth-Name";
          enable_login_token = true;
        };

        feature_toggles = {
          enable = "traceToMetrics";
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString promcfg.port}";
            jsonData = {
              scrape_interval = "15s";
            };
          }
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:${toString lokicfg.port}";
            jsonData = {
              derivedFields = [
                {
                  datasourceUid = "Tempo";
                  matcherRegex = "\"trace_id\":\"(\\w+)\"";
                  name = "Trace ID";
                  url = "$${__value.raw}";
                }
              ];
            };
          }
          {
            name = "Tempo";
            type = "tempo";
            url = "http://localhost:${toString tempocfg.port}";
            jsonData = {
              tracesToLogs = {
                datasourceUid = "Loki";
                mappedTags = [
                  {
                    key = "service.name";
                    value = "service";
                  }
                ];
                mapTagNamesEnabled = true;
                filterByTraceID = true;
              };
              tracesToMetrics = {
                datasourceUid = "Prometheus";
              };
            };
          }
        ];
      };
    };

    users.users.proxy-to-grafana = {
      createHome = true;
      description = "proxy-to-grafana";
      isSystemUser = true;
      group = "proxy-to-grafana";
      home = "/srv/proxy-to-grafana";
    };

    users.groups.proxy-to-grafana = { };

    systemd.services.proxy-to-grafana = {
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "proxy-to-grafana";
        Group = "proxy-to-grafana";
        Restart = "on-failure";
        WorkingDirectory = "/srv/proxy-to-grafana";
      };

      script = ''
        export TS_HOSTNAME="${cfg.hostname}"
        export GRAFANA_ADDR="127.0.0.1:${builtins.toString cfg.port}"
        export TS_AUTHKEY="$(cat ${config.age.secrets."${cfg.secrets.tailscaleAuthkey}".path})"
        ${pkgs.tailscale}/bin/proxy-to-grafana --use-https=true --hostname=$TS_HOSTNAME --backend-addr=$GRAFANA_ADDR
      '';
    };
  };
}

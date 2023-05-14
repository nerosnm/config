{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.neros-dev;

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.neros-dev = {
      enable = mkEnableOption "Activate the various webpages hosted under neros.dev";

      port = mkOption rec {
        description = ''
          Port for neros.dev
        '';
        type = types.int;
        default = 3000;
        example = default;
      };

      secrets = mkOption {
        description = "Names of secrets for use in this module";

        type = types.submodule {
          options = { };
        };
      };

      loki = mkOption {
        description = "Options for exporting logs to Loki";

        type = types.submodule {
          options = {
            host = mkOption rec {
              description = ''
                Host that Loki is running on
              '';
              type = types.str;
              example = "loki";
            };

            port = mkOption rec {
              description = ''
                Port for Loki
              '';
              type = types.int;
              example = 9003;
            };
          };
        };
      };

      tempo = mkOption {
        description = "Options for exporting traces to Tempo";

        type = types.submodule {
          options = {
            host = mkOption rec {
              description = ''
                Host that Tempo is running on
              '';
              type = types.str;
              example = "tempo";
            };

            port = mkOption rec {
              description = ''
                Port for Tempo
              '';
              type = types.int;
              example = 4317;
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Expose the HTTP and HTTPS ports to the public internet
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.nginx = {
      enable = true;

      virtualHosts."neros.dev" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };

    users.users.neros-dev = {
      createHome = true;
      description = "github.com/nerosnm/neros.dev";
      isSystemUser = true;
      group = "neros-dev";
      home = "/srv/neros-dev";
    };

    users.groups.neros-dev = { };

    systemd.services.neros-dev = {
      wantedBy = [ "multi-user.target" ];
      after = [ ];
      wants = [ ];

      serviceConfig = {
        User = "neros-dev";
        Group = "neros-dev";
        Restart = "on-failure";
        WorkingDirectory = "/srv/neros-dev";
        RestartSec = "30s";
      };

      script = ''
        export PORT=${toString cfg.port}
        export RUST_LOG="neros_dev=info"
        export ENVIRONMENT="production"
        export CONTENT_PATH=${pkgs.neros-dev-content}
        export STATIC_PATH=${pkgs.neros-dev-static}
        export STYLESHEET_PATH=${pkgs.neros-dev-stylesheet}/style.css
        export LOKI_ENDPOINT="http://${cfg.loki.host}:${builtins.toString cfg.loki.port}"
        export TRACING_ENDPOINT="http://${cfg.tempo.host}:${builtins.toString cfg.tempo.port}"
        ${pkgs.neros-dev}/bin/neros-dev
      '';
    };
  };
}

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
        export CONTENT_PATH=${pkgs.neros-dev-content}
        export STATIC_PATH=${pkgs.neros-dev-static}
        export STYLESHEET_PATH=${pkgs.neros-dev-stylesheet}/style.css
        ${pkgs.neros-dev}/bin/neros-dev
      '';
    };
  };
}

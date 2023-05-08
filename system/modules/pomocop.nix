{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.pomocop;

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.pomocop = {
      enable = mkEnableOption "Pomocop Discord bot";

      secrets = mkOption {
        description = "Names of secrets for use in this module";

        type = types.submodule {
          options = {
            token = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Discord token for
                Pomocop. The owner and group should both be "pomocop".
              '';
              type = types.str;
              example = "pomocop-discord-token";
            };

            applicationId = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Application ID for
                Pomocop. The owner and group should both be "pomocop".
              '';
              type = types.str;
              example = "pomocop-application-id";
            };

            ownerId = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Owner ID for
                Pomocop. The owner and group should both be "pomocop".
              '';
              type = types.str;
              example = "pomocop-owner-id";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.pomocop = {
      createHome = true;
      description = "github.com/nerosnm/pomocop";
      isSystemUser = true;
      group = "pomocop";
      home = "/srv/pomocop";
    };

    users.groups.pomocop = { };

    systemd.services.pomocop = {
      wantedBy = [ "multi-user.target" ];
      after = [ ];
      wants = [ ];

      serviceConfig = {
        User = "pomocop";
        Group = "pomocop";
        Restart = "on-failure";
        WorkingDirectory = "/srv/pomocop";
        RestartSec = "30s";
      };

      script = ''
        export TOKEN=$(cat ${config.age.secrets."${cfg.secrets.token}".path})
        export APPLICATION_ID=$(cat ${config.age.secrets."${cfg.secrets.applicationId}".path})
        export OWNER_ID=$(cat ${config.age.secrets."${cfg.secrets.ownerId}".path})
        export RUST_LOG="info,pomocop=debug"
        ${pkgs.pomocop}/bin/pomocop
      '';
    };
  };
}

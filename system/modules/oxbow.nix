{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.oxbow;

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.oxbow = {
      enable = mkEnableOption "Oxbow Twitch chat bot";

      secrets = mkOption {
        description = "Names of secrets for use in this module";

        type = types.submodule {
          options = {
            clientId = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Twitch client ID for
                Oxbow. The owner and group should both be "oxbow".
              '';
              type = types.str;
              example = "oxbow-client-id";
            };

            clientSecret = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Twitch client secret
                for Oxbow. The owner and group should both be "oxbow".
              '';
              type = types.str;
              example = "oxbow-client-secret";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.oxbow = {
      createHome = true;
      description = "github.com/nerosnm/oxbow";
      isSystemUser = true;
      group = "oxbow";
      home = "/srv/oxbow";
    };

    users.groups.oxbow = { };

    systemd.services.oxbow = {
      wantedBy = [ "multi-user.target" ];
      after = [ ];
      wants = [ ];

      serviceConfig = {
        User = "oxbow";
        Group = "oxbow";
        Restart = "on-failure";
        WorkingDirectory = "/srv/oxbow";
        RestartSec = "30s";
      };

      script = ''
        export CLIENT_ID=$(cat ${config.age.secrets."${cfg.secrets.clientId}".path})
        export CLIENT_SECRET=$(cat ${config.age.secrets."${cfg.secrets.clientSecret}".path})
        export TWITCH_NAME="oxoboxowot"
        export DATABASE=./oxbow.sqlite3
        export RUST_LOG="info,oxbow=debug"
        ${pkgs.oxbow}/bin/oxbow --channels nerosnm stuck_overflow ninthroads fisken_ai exodiquas theidofalan
      '';
    };
  };
}

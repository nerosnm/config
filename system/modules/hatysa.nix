{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.hatysa;

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.hatysa = {
      enable = mkEnableOption "Hatysa Discord bot";

      secrets = mkOption {
        description = "Names of secrets for use in this module";

        type = types.submodule {
          options = {
            discordToken = mkOption rec {
              description = ''
                Name of the agenix secret that contains the Discord token for
                Hatysa. The owner and group should both be "hatysa".
              '';
              type = types.str;
              example = "hatysa-discord-token";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.hatysa = {
      createHome = true;
      description = "github.com/nerosnm/hatysa";
      isSystemUser = true;
      group = "hatysa";
      home = "/srv/hatysa";
    };

    users.groups.hatysa = { };

    systemd.services.hatysa = {
      wantedBy = [ "multi-user.target" ];
      after = [ ];
      wants = [ ];

      serviceConfig = {
        User = "hatysa";
        Group = "hatysa";
        Restart = "on-failure";
        WorkingDirectory = "/srv/hatysa";
        RestartSec = "30s";
      };

      script = ''
        export DISCORD_TOKEN=$(cat ${config.age.secrets."${cfg.secrets.discordToken}".path})
        export HATYSA_PREFIX=","
        export RUST_LOG="info,hatysa=debug,iota_orionis=debug"
        ${pkgs.hatysa}/bin/hatysa
      '';
    };
  };
}

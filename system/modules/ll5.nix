{ config
, lib
, pkgs
, ...
}:

with lib;
let
  cfg = config.nerosnm.services.ll5;
in
{
  options = {
    nerosnm.services.ll5 = {
      enable = mkEnableOption "Activate the LL5 Minecraft server on this host";

      port = mkOption {
        description = ''
          Port to expose the Minecraft server over. This must match the value in server.properties.
        '';
        type = types.int;
        default = 25565;
        example = 25569;
      };

      rconPort = mkOption {
        description = ''
          Port to connect to RCON through. This must match the value in server.properties.
        '';
        type = types.int;
        default = 25575;
        example = 25579;
      };

      memory = mkOption {
        description = ''
          How many MB of memory to dedicate to the server.
        '';
        type = types.int;
        default = 3072;
        example = 2048;
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.minecraft = {
      createHome = true;
      description = "LL5 Minecraft server service user";
      isSystemUser = true;
      group = "minecraft";
      home = "/srv/ll5";
    };

    users.groups.minecraft = { };

    systemd.services.ll5 = {
      description = "LL5 Minecraft Server Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.jdk}/bin/java -Xms${toString cfg.memory}M -Xmx${toString cfg.memory}M @libraries/net/minecraftforge/forge/1.18.2-40.2.0/unix_args.txt nogui";
        Restart = "always";
        User = "minecraft";
        WorkingDirectory = "/srv/ll5";
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}

{ self
, config
, lib
, pkgs
, ...
}:

let
  cfg = config.services.buildkite;

  inherit (lib) mkIf;
in
{
  options.services.buildkite = with lib; {
    enable = mkEnableOption "BuildKite agent";
  };

  config = mkIf cfg.enable {
    services.buildkite-agents.${config.networking.hostName} = {
      inherit (cfg) enable;
      name = "nixos-%hostname-%n";
      tokenPath = "/run/agenix/buildkite-token";
      privateSshKeyPath = "/run/agenix/buildkite-ssh-dalim";

      tags = {
        queue = "nixos";
      };

      extraConfig = ''
        tags-from-host=true
      '';
    };

    nix.settings.allowed-users = [ "buildkite-agent-${config.networking.hostName}" ];

    age.secrets.buildkite-token = {
      file = "${self}/secrets/buildkite-token.age";
      owner = "buildkite-agent-${config.networking.hostName}";
    };

    age.secrets."buildkite-ssh-dalim.pub" = {
      file = "${self}/secrets/buildkite-ssh-dalim.pub.age";
      owner = "buildkite-agent-${config.networking.hostName}";
    };

    age.secrets."buildkite-ssh-dalim" = {
      file = "${self}/secrets/buildkite-ssh-dalim.age";
      owner = "buildkite-agent-${config.networking.hostName}";
    };

    systemd.services."buildkite-agent-${config.networking.hostName}" = {
      # confinement.enable = true;
      # confinement.packages = config.services.buildkite-agents.${config.networking.hostName}.runtimePackages;
      serviceConfig = {
        BindReadOnlyPaths = [
          config.services.buildkite-agents.${config.networking.hostName}.tokenPath
          config.services.buildkite-agents.${config.networking.hostName}.privateSshKeyPath
          "${config.environment.etc."ssl/certs/ca-certificates.crt".source}:/etc/ssl/certs/ca-certificates.crt"
          "/etc/machine-id"
          # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
          "/nix/store"
        ];
        BindPaths = [
          config.services.buildkite-agents.${config.networking.hostName}.dataDir
          "/nix/var/nix/daemon-socket/socket"
        ];
      };
    };
  };
}

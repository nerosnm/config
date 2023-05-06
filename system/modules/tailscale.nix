{ config
, lib
, pkgs
, ...
}:

with lib;
let
  cfg = config.nerosnm.services.tailscale;
in
{
  options = {
    nerosnm.services.tailscale = {
      enable = mkEnableOption "Activate Tailscale on this host";
      trustInterface = mkEnableOption "Add tailscale0 to the firewall's trusted interfaces";

      authKey = mkOption {
        description = ''
          Tailscale authorization key for this host. If it begins with "file:",
          then it's a path to the file containing the authkey.
        '';
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    # Allow the Tailscale UDP port through the firewall
    networking.firewall = {
      trustedInterfaces = optional cfg.trustInterface "tailscale0";
      allowedUDPPorts = [
        config.services.tailscale.port
      ];
    };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to tailscale";

      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script = ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          echo "already authenticated, doing nothing"
          exit 0
        fi

        # otherwise authenticate with tailscale
        echo "authenticating..."
        ${pkgs.tailscale}/bin/tailscale up -authkey ${cfg.authKey}
      '';
    };

    assertions = [
      {
        assertion = cfg.authKey != "";
        message = "Tailscale authKey cannot be empty";
      }
    ];
  };
}

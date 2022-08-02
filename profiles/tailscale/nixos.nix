{ self
, config
, pkgs
, ...
}:

{
  services.tailscale.enable = true;

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
      ${pkgs.tailscale}/bin/tailscale up -authkey "file:/run/agenix/tailscale-authkey"
    '';
  };

  networking.firewall = {
    # Allow traffic from my Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];

    # According to Tailscale, strict path filtering breaks Tailscale exit
    # node use and some subnet routing setups.
    checkReversePath = "loose";
  };

  networking.nameservers = [ "100.100.100.100" "8.8.8.8" "1.1.1.1" ];
  networking.search = [ "example.com.beta.tailscale.net" ];
}

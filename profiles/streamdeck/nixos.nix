{ self
, pkgs
, ...
}:

{
  environment.systemPackages =
    let
      streamdeck-config = pkgs.writeShellScriptBin
        "streamdeck-config"
        "systemctl stop --user streamdeck && ${pkgs.streamdeck-ui}/bin/streamdeck && systemctl start --user streamdeck";
    in
    with pkgs; [
      streamdeck-ui
      streamdeck-config
      xdotool
    ];

  systemd.user.services.streamdeck = {
    description = "Background streamdeck-ui process";

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    path = with pkgs; [
      xdotool
    ];

    script = "${pkgs.streamdeck-ui}/bin/streamdeck -n";
  };
}

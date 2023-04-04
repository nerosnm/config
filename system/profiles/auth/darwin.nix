{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./common.nix
  ];

  environment.systemPackages = with pkgs; [
    openssh
  ];

  launchd.user.agents.ssh-agent = {
    path = [ config.environment.systemPath ];
    command = "${pkgs.openssh}/bin/ssh-agent -D -a /tmp/ssh-agent.sock";
    serviceConfig.KeepAlive = true;
  };

  environment.extraInit = ''
    export SSH_AUTH_SOCK="/tmp/ssh-agent.sock"
  '';
}

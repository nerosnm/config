{ config
, hmUsers
, self
, ...
}:

{
  imports = [ ./common.nix ];

  users.users.soren = {
    home = "/home/soren";
    createHome = true;

    passwordFile = "/run/agenix/soren-pwhash";
    openssh.authorizedKeys.keys = map builtins.readFile [
      ../../keys/soren.pub
    ];

    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "qemu-libvirtd" ];
  };

  age.secrets.soren-pwhash.file = "${self}/secrets/soren-pwhash.age";
}

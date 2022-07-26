{ config
, ...
}:

{
  imports = [ ./common.nix ];

  users.users.soren = {
    name = "soren";
    home = "/Users/soren";
  };
}

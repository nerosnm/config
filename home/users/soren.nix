{ config
, lib
, pkgs
, ...
}:

{
  home = {
    username = "soren";
    homeDirectory = "/Users/soren";

    stateVersion = "22.11";

    file.".ssh/id_ed25519_sk.pub".source = ../../keys/soren.pub;
  };

  custom = {
    nvim.enable = true;

    auth = {
      publicKeys = [
        { host = "*"; path = "~/.ssh/id_ed25519_sk"; }
      ];
      allowedSigners = [
        { email = "soren@ditto.live"; key = (builtins.readFile ../../keys/soren.pub); }
        { email = "soren@neros.dev"; key = (builtins.readFile ../../keys/soren.pub); }
      ];
    };

    git = {
      enable = true;

      user = {
        name = "Søren Mortensen";
        email = "soren@neros.dev";
        key = "~/.ssh/id_ed25519_sk";
      };

      includes =
        let
          ditto-include = pkgs.writeText "config-ditto-include" ''
            [user]
                email = "soren@ditto.live"
          '';
        in
        [
          {
            condition = "gitdir:~/src/github.com/getditto/";
            path = ditto-include;
          }
        ];
    };

    irc = {
      enable = true;
      servers = {
        defaults = {
          nick = "nerosnm";
          real = "soren";
          notify = true;
          quiet = true;
        };

        libera = {
          host = "libera.neros.dev";
          user = "nerosnm";
          cert = "/run/agenix/soren-libera-cert";
          join = [
            "##rust"
            "#nixos"
            "#latex"
            "#coffee"
            "#mechboards"
            "#gaygeeks"
            "##music"
            "##English"
          ];
        };
      };
    };
  };
}

{ config, ... }: {
  imports = [
    ../non-work.nix
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.ssh/id_ed25519_maddie_polaris"
  ];

  age.secrets.catgirl-polaris-libera = {
    file = ../../secrets/catgirl-polaris-libera.age;
    path = "${config.home.homeDirectory}/.config/catgirl/libera";
  };

  age.secrets.catgirl-polaris-libera-cert = {
    file = ../../secrets/irc-polaris-libera.pem.age;
    path = "${config.home.homeDirectory}/.config/catgirl/libera.pem";
  };

  age.secrets.catgirl-polaris-snoonet = {
    file = ../../secrets/catgirl-polaris-snoonet.age;
    path = "${config.home.homeDirectory}/.config/catgirl/snoonet";
  };

  age.secrets.catgirl-polaris-snoonet-cert = {
    file = ../../secrets/irc-polaris-snoonet.pem.age;
    path = "${config.home.homeDirectory}/.config/catgirl/snoonet.pem";
  };

  age.secrets.halloy-polaris-config = {
    file = ../../secrets/halloy-polaris-config.toml.age;
    path = "${config.home.homeDirectory}/.config/halloy/config.toml";
  };

  age.secrets.id_ed25519_jj_wtf = {
    file = ../../secrets/id_ed25519_jj_wtf.age;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519_jj_wtf";
  };

  age.secrets.id_ed25519_sk_maddie_wtf = {
    file = ../../secrets/id_ed25519_sk_maddie_wtf.age;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519_sk_maddie_wtf";
  };

  age.secrets.irc-polaris-libera-cert = {
    file = ../../secrets/irc-polaris-libera.pem.age;
    path = "${config.home.homeDirectory}/.local/share/irc/libera.pem";
  };

  age.secrets.irc-polaris-snoonet-cert = {
    file = ../../secrets/irc-polaris-snoonet.pem.age;
    path = "${config.home.homeDirectory}/.local/share/irc/snoonet.pem";
  };

  home = {
    file.".ssh/id_ed25519_jj_wtf.pub".source = ../../keys/maddie-jj-wtf.pub;
    file.".ssh/id_ed25519_sk_maddie_wtf.pub".source = ../../keys/maddie-wtf.pub;

    stateVersion = "22.11";
  };

  xdg.configFile."jj/conf.d/20-polaris.toml".text = ''
    [signing]
    key = "~/.ssh/id_ed25519_jj_wtf.pub"
  '';

  custom = {
    auth = {
      publicKeys = {
        "*" = "~/.ssh/id_ed25519_sk_maddie_wtf";
      };
    };

    beancount.enable = true;

    git = {
      user = {
        signingKey = "~/.ssh/id_ed25519_sk_maddie_wtf";
      };
    };
  };
}

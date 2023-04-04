{ config
, pkgs
, ...
}:

{
  imports = [
    ../base/darwin.nix

    ../profiles/auth/darwin.nix
    ../profiles/collab/darwin.nix
    ../profiles/dev/darwin.nix
    ../profiles/utility/darwin.nix
  ];

  users = {
    # TODO: Figure out if there's a way to default this (in ../base/darwin.nix),
    # rather than setting it for individual users.
    users.soren.shell = pkgs.zsh;
  };

  age.secrets.ditto-license = {
    file = ../../secrets/ditto-license.age;
    owner = "soren";
  };
  age.secrets.quay-email-ditto = {
    file = ../../secrets/quay-email-ditto.age;
    owner = "soren";
  };
  age.secrets.quay-token-ditto = {
    file = ../../secrets/quay-token-ditto.age;
    owner = "soren";
  };
  age.secrets.quay-user-ditto = {
    file = ../../secrets/quay-user-ditto.age;
    owner = "soren";
  };
  environment.extraInit = ''
    export DITTO_LICENSE="$(cat ${config.age.secrets.ditto-license.path})"
    export QUAY_EMAIL="$(cat ${config.age.secrets.quay-email-ditto.path})"
    export QUAY_TOKEN="$(cat ${config.age.secrets.quay-token-ditto.path})"
    export QUAY_USER="$(cat ${config.age.secrets.quay-user-ditto.path})"
  '';
}

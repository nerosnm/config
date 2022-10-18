{ self
, config
, ...
}:

{
  age.secrets.ditto-quay-token = {
    file = "${self}/secrets/ditto-quay-token.age";
    owner = "soren";
  };
  age.secrets.ditto-quay-user = {
    file = "${self}/secrets/ditto-quay-user.age";
    owner = "soren";
  };
  age.secrets.ditto-quay-email = {
    file = "${self}/secrets/ditto-quay-email.age";
    owner = "soren";
  };

  environment.shellInit = ''
    export QUAY_TOKEN_PATH="${config.age.secrets.ditto-quay-token.path}"
    export QUAY_USER="$(cat ${config.age.secrets.ditto-quay-user.path})"
    export QUAY_EMAIL="$(cat ${config.age.secrets.ditto-quay-email.path})"
  '';
}

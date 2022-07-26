{ self
, ...
}:

{
  users.users.root = {
    passwordFile = "/run/agenix/root-pwhash";
    openssh.authorizedKeys.keys = map builtins.readFile [
      ../keys/soren.pub
    ];
  };

  age.secrets.root-pwhash.file = "${self}/secrets/root-pwhash.age";
}

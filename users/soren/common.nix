{ self
, config
, hmUsers
, ...
}:

{
  home-manager.users = { inherit (hmUsers) soren; };

  users.users.soren = {
    description = "Søren Mortensen";
  };

  age.secrets.soren-libera-cert.file = "${self}/secrets/soren-libera-cert.age";
}

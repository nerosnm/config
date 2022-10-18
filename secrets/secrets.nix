let
  inherit (builtins) mapAttrs readFile;

  # Public keys of specific machines.
  talitha = readFile ../keys/talitha.pub;
  dalim = readFile ../keys/dalim.pub;

  # Each of the secrets is given a list of public keys that should be used to 
  # encrypt them. Right now, only the machine-specific keys from above are added 
  # to the list for each secret, because these are the keys that will not 
  # necessarily be given access to every secret.
  secrets = {
    "buildkite-ssh-dalim.age".publicKeys = [ dalim ];
    "buildkite-ssh-dalim.pub.age".publicKeys = [ dalim ];
    "buildkite-token.age".publicKeys = [ dalim ];
    "cachix-ditto-token.age".publicKeys = [ dalim ];
    "root-pwhash.age".publicKeys = [ dalim talitha ];
    "soren-libera-cert.age".publicKeys = [ dalim talitha ];
    "soren-pwhash.age".publicKeys = [ dalim talitha ];
    "tailscale-talitha.age".publicKeys = [ talitha ];
    "ditto-quay-token.age".publicKeys = [ dalim ];
    "ditto-quay-user.age".publicKeys = [ dalim ];
    "ditto-quay-email.age".publicKeys = [ dalim ];
  };

  # Public key of an age-plugin-yubikey key, the counterpart to the keygrip 
  # `./identities/soren-yubikey.txt`.
  #
  # This is not my main Yubikey SSH key (`../keys/soren.pub`), because that 
  # can't be used with agenix at the moment.
  soren-yubikey = "age1yubikey1q2rz3aqs37q2t2asrpvf274pukm6ez6kv4cc0wpmft5k0fm009aj66hrlez";

  # Keys that should always be able to access every secret, so they can be used 
  # to access and re-encrypt secrets.
  general = [
    soren-yubikey
  ];
in
# Map each secret's `publicKeys` list to a new one that also includes `general`.
mapAttrs
  (_: secret: { publicKeys = secret.publicKeys ++ general; })
  secrets

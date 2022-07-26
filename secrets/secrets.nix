let
  inherit (builtins) readFile;

  talitha = readFile ../keys/talitha.pub;

  allKeys = [ talitha ];
in
{
  "root-pwhash.age".publicKeys = [ talitha ];
  "soren-pwhash.age".publicKeys = [ talitha ];
  "datadog-api-key.age".publicKeys = [ talitha ];
  "tailscale-talitha.age".publicKeys = [ talitha ];
  "soren-libera-cert.age".publicKeys = [ talitha ];
}

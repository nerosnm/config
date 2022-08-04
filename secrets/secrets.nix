let
  inherit (builtins) readFile;

  talitha = readFile ../keys/talitha.pub;
  dalim = readFile ../keys/dalim.pub;

  allKeys = [ talitha ];
in
{
  "root-pwhash.age".publicKeys = [ talitha dalim ];
  "soren-pwhash.age".publicKeys = [ talitha dalim ];
  "datadog-api-key.age".publicKeys = [ talitha dalim ];
  "buildkite-token.age".publicKeys = [ dalim ];
  "buildkite-ssh-dalim.pub.age".publicKeys = [ dalim ];
  "buildkite-ssh-dalim.age".publicKeys = [ dalim ];
  "tailscale-talitha.age".publicKeys = [ talitha ];
  "soren-libera-cert.age".publicKeys = [ talitha dalim ];
}

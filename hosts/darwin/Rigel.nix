{ self
, profiles
, suites
, ...
}:

{
  imports = suites.home ++ (with profiles; [
    moonlander.darwin
    stream.darwin
    tailscale.darwin
  ]);
}

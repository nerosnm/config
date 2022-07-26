{ self
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    tectonic
    python39Packages.pygments
  ];
}

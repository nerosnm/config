{ self
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    darktable
    rawtherapee
  ];
}

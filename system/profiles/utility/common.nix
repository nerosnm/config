{ config
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    cachix
    doing
    tectonic
    python39Packages.pygments
  ];

  environment.variables.TERMINFO_DIRS = [
    "${pkgs.wezterm.terminfo}/share/terminfo"
  ];
}

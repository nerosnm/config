{ self
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    doing
    tectonic
    python39Packages.pygments
  ];

  programs.zsh.interactiveShellInit = ''
    source ${pkgs.wezterm}/etc/profile.d/wezterm.sh
    export TERM=wezterm
  '';
}

{ self
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    _1password
    _1password-gui
    dia
    firefox-devedition-bin
    gnucash
    gparted
    lagrange
    libreoffice
    mpv
    qjackctl
    spotify
    wezterm
    zathura
  ];

  environment.etc."zathurarc".text = ''
    set guioptions none
  '';
}

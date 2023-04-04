{ config
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    _1password
    _1password-gui
    dia
    gnucash
    gparted
    lagrange
    libreoffice
    mpv
    qjackctl
    spotify
    wezterm
    zathura

    (firefox-devedition-bin.overrideAttrs (old: {
      desktopItem = (old.desktopItem.override (d: {
        desktopName = "Firefox Developer Edition";
      }));
    }))
  ];

  environment.etc."zathurarc".text = ''
    set guioptions none
  '';

  programs.zsh.interactiveShellInit = ''
    source ${pkgs.wezterm}/etc/profile.d/wezterm.sh
    export TERM=wezterm
  '';
}

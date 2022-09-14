{ config, lib, pkgs, self, ... }:

{
  imports = [
    ./common.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      (pkgs.runCommand "catgirl" { buildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir $out
        ln -s ${pkgs.catgirl}/* $out
        rm $out/bin
        mkdir $out/bin
        ln -s ${pkgs.catgirl}/bin/* $out/bin
        rm $out/bin/catgirl
        makeWrapper ${pkgs.catgirl}/bin/catgirl $out/bin/catgirl \
          --set TERM wezterm
      '')
      dosfstools
      gptfdisk
      iputils
      lm_sensors
      usbutils
      utillinux
    ];

    shellAliases =
      let
        ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # nix
        nrb = ifSudo "sudo nixos-rebuild";

        # fix nixos-option for flake compat
        nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";
      };
  };

  users.mutableUsers = false;

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Iosevka" ];
  };

  nix = {
    # Improve nix store disk usage
    settings.auto-optimise-store = true;
    optimise.automatic = true;
    settings.allowed-users = [ "@wheel" ];
    # This is just a representation of the nix default
    settings.system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  };

  programs.bash = {
    # Enable starship
    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
    # Enable direnv, a tool for managing shell environments
    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };

  programs.zsh = {
    # Enable starship
    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
    # Enable direnv, a tool for managing shell environments
    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
  };

  # For rage encryption, all hosts need a ssh key pair
  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };

  # Service that makes Out of Memory Killer more effective
  services.earlyoom.enable = true;

  # Localisation settings
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  # Set X keyboard layouts to gb and dk, and enable toggling between them with 
  # alt-space
  services.xserver.layout = "gb,dk";
  services.xserver.xkbOptions = "grp:alt_space_toggle";
}

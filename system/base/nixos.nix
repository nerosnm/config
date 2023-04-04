{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./common.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      dosfstools
      gptfdisk
      iputils
      lm_sensors
      usbutils
      utillinux
    ];

    variables = {
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
    };

    # Starship is a fast and featureful shell prompt
    # starship.toml has sane defaults that can be changed there
    shellInit =
      let
        starshipConfig = lib.fileContents ../../static/starship.toml;
        starshipToml = pkgs.writeText "starship.toml" starshipConfig;
      in
      ''
        export STARSHIP_CONFIG=${starshipToml}
        ulimit -n 4096
      '';
  };

  users.mutableUsers = false;

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Iosevka" ];
  };

  nix = {
    optimise.automatic = true;

    settings = {
      auto-optimise-store = true;
      allowed-users = [ "@wheel" ];

      # This is just a representation of the nix default
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    };
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
  users.defaultUserShell = pkgs.zsh;

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

  age.secrets.root-pwhash.file = ../../secrets/root-pwhash.age;
  age.secrets.soren-pwhash.file = ../../secrets/soren-pwhash.age;

  age.secrets.soren-libera-cert = {
    file = ../../secrets/soren-libera-cert.age;
    owner = "soren";
  };

  users.users = {
    root = {
      passwordFile = config.age.secrets.root-pwhash.path;
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../../keys/soren.pub)
      ];
    };

    soren = {
      description = "Søren Mortensen";

      home = "/home/soren";
      createHome = true;

      passwordFile = config.age.secrets.soren-pwhash.path;
      openssh.authorizedKeys.keys = [
        (builtins.readFile ../../keys/soren.pub)
      ];

      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "qemu-libvirtd" "docker" ];
    };
  };
}

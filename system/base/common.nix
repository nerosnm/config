{ config
, pkgs
, ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      asciiquarium
      bat
      bottom
      curl
      dig
      direnv
      erdtree
      eza
      fd
      fzf
      git
      glow
      hyperfine
      jq
      keybase
      openssh
      ripgrep
      sd
      tokei
    ];
  };

  nix = {
    settings = {
      # Prevents impurities in builds
      sandbox = "relaxed";

      # Give root user and wheel group special Nix privileges.
      trusted-users = [ "root" "@wheel" ];

      extra-experimental-features = "nix-command flakes";

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Improve nix store disk usage
    gc.automatic = true;

    # Generally useful nix option defaults
    extraOptions = ''
      min-free = 536870912
      keep-outputs = true
      keep-derivations = true
      fallback = true
    '';
  };

  fonts.fonts = with pkgs; [
    iosevka-custom
  ];
}

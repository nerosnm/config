{ self
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment.systemPackages = with pkgs; [
    rustup
  ];

  homebrew.casks = [
    "insomnia"
  ];
}

{ self
, ...
}:

{
  imports = [ ./common.nix ];

  homebrew.casks = [
    "obs"
  ];
}

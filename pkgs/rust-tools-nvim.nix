{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "simrat39";
  repo = "rust-tools.nvim";
  rev = "0cc8adab23117783a0292a0c8a2fbed1005dc645";
  sha256 = "sha256-jtfyDxifchznUupLSao6nmpVqaX1yO0xN+NhqS9fgxg=";
in

vimUtils.buildVimPluginFrom2Nix {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

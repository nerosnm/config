{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "rust-lang";
  repo = "rust.vim";
  rev = "889b9a7515db477f4cb6808bef1769e53493c578";
  sha256 = "sha256-70kp644jOtJ4wguty/SUFX+YEsoxW12LGg3vZh7BdPY=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

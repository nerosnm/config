{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "tzachar";
  repo = "fuzzy.nvim";
  rev = "67a42ad2fa6d5ff41f0ef3cf69bb247410da5d7a";
  sha256 = "sha256-mAlsE5fQTTdVVjOrV2/fNyHRhndW95s1xdzmiFLffsI=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

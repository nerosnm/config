{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "ellisonleao";
  repo = "carbon-now.nvim";
  rev = "3caa535a6216a8f3152708ae0fe6087b76e58639";
  sha256 = "sha256-fvu0wYfdt0Ru7QD1sMmOUzvYaRyGRh4koLnkPplPmwE=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

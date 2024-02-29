{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "nerosnm";
  repo = "git-blame.nvim";
  rev = "c14d43806db2bd51da5c83879505ce054577735c";
  sha256 = "sha256-QTYrjmdw9m49rgfGXIToXaEFojVeMvTBydKWt958GNM=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

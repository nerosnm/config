{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "f-person";
  repo = "git-blame.nvim";
  rev = "1792125237260dc2a03ba57d31c39179e6049f07";
  sha256 = "sha256-jq3ii4CFa5hpbRMJe9zxl7fVMs/BgWfwBBmEtqn/Bok=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

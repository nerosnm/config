{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "nvim-telescope";
  repo = "telescope-file-browser.nvim";
  rev = "6e51d0cd6447cf2525412220ff0a2885eef9039c";
  sha256 = "sha256-OMUsmrn4A351p95KXHxW4B8etRuKnpHk9tJ2tQUXXc8=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

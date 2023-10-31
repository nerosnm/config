{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "tzachar";
  repo = "cmp-fuzzy-path";
  rev = "acdb3d74ff32325b6379e68686fe489c3da29b0a";
  sha256 = "sha256-hHkjYLO6WYIaXhAx7Oo0q0dHXenH2+6x9Te//L/XaDM=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

{ lib
, vimUtils
, fetchFromGitHub
}:

let
  owner = "pest-parser";
  repo = "pest.vim";
  rev = "78a65344a89804ec86a0d025a3799f47c2331389";
  sha256 = "sha256-LYIFw4slkxQ41V95GpQ5KVMKIoKK5n+rpea3Bgc7bAU=";
in

vimUtils.buildVimPlugin {
  pname = repo;
  version = rev;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };
}

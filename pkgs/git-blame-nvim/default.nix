{ sources, vimUtils }:

vimUtils.buildVimPlugin {
  pname = "git-blame.nvim";
  inherit (sources.git-blame-nvim) version src;
}

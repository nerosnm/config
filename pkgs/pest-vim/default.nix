{ sources, vimUtils }:

vimUtils.buildVimPlugin {
  pname = "pest.vim";
  inherit (sources.pest-vim) version src;
}

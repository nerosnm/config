{ sources, vimUtils }:

vimUtils.buildVimPlugin {
  inherit (sources.vim-dogrun) pname version src;
}

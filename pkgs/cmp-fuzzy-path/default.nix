{ sources, vimUtils }:

vimUtils.buildVimPlugin {
  inherit (sources.cmp-fuzzy-path) pname version src;
}

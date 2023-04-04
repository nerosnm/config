{ sources, vimUtils }:

vimUtils.buildVimPlugin {
  pname = "key-menu.nvim";
  inherit (sources.key-menu-nvim) version src;
}

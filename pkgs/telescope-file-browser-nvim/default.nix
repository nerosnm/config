{ sources, vimUtils }:

vimUtils.buildVimPluginFrom2Nix {
  pname = "telescope-file-browser.nvim";
  inherit (sources.telescope-file-browser-nvim) version src;
}

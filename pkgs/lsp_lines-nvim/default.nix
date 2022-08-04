{ sources, vimUtils }:

vimUtils.buildVimPluginFrom2Nix {
  pname = "lsp_lines.nvim";
  inherit (sources.lsp_lines-nvim) version src;
}

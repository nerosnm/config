{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.custom.nvim.lsp;
  parent = config.custom.nvim;

  luaPlugin = plugin: configPath: {
    inherit plugin;
    type = "lua";
    config = builtins.readFile configPath;
  };

  luaPluginInline = plugin: config: {
    inherit plugin config;
    type = "lua";
  };

  inherit (lib) mkIf mkOverride optionals;
in
{
  options.custom.nvim.lsp = with lib; {
    enable = mkOption rec {
      description = "Whether to enable and configure LSP-related neovim plugins";
      type = types.bool;
      default = true;
      example = !default;
    };
  };

  config = mkIf (parent.enable && cfg.enable) {
    programs.neovim = {
      plugins = with pkgs; with vimPlugins; [
        cmp-cmdline
        cmp-fuzzy-path
        cmp-nvim-lsp
        cmp_luasnip
        fuzzy-nvim
        lspkind-nvim
        luasnip

        (luaPlugin fidget-nvim ./config/fidget.lua)
        (luaPlugin nvim-cmp ./config/nvim-cmp.lua)
        (luaPlugin nvim-lspconfig ./config/lspconfig.lua)
        (luaPlugin pkgs.rust-tools-nvim ./config/rust-tools.lua)
        (luaPlugin vim-illuminate ./config/illuminate.lua)
      ];

      extraPackages = with pkgs; [
        # ccls # For C/C++ completions
        rnix-lsp # Nix language server
        texlab # TeX language server
        # python311Packages.python-lsp-server

        # These cause ghc compilation:
        # nodePackages.bash-language-server # Bash language server
        # shellcheck # For Bash
      ];
    };
  };
}

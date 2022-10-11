{ self
, config
, lib
, pkgs
, ...
}:

let
  cfg = config.nvim.lsp;
  parent = config.nvim;

  luaPlugin = plugin: configPath: {
    inherit plugin;
    type = "lua";
    config = builtins.readFile configPath;
  };

  inherit (lib) mkIf mkOverride optionals;
in
{
  options.nvim.lsp = with lib; {
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
        (luaPlugin rust-tools-nvim ./config/rust-tools.lua)
      ];

      extraPackages = with pkgs; [
        # ccls # For C/C++ completions
        nodePackages.bash-language-server # Bash language server
        rnix-lsp # Nix language server
        shellcheck # For Bash
        texlab # TeX language server
      ];
    };
  };
}

require'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting=false,
    },
}

vim.api.nvim_set_hl(0, "@definition.doc", { link = "SpecialComment" })
-- require'nvim-treesitter.highlight'.set_custom_captures {
--     ["definition.doc"] = "SpecialComment",
-- }

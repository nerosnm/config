require'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
    },
}

require'nvim-treesitter.highlight'.set_custom_captures {
    ["definition.doc"] = "SpecialComment",
}

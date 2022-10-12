require'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting=false,
    },
}

require'nvim-treesitter.highlight'.set_custom_captures {
    ["definition.doc"] = "SpecialComment",
}

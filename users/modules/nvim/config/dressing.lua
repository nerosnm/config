require'dressing'.setup{
    select = {
        telescope = require'telescope.themes'.get_cursor { }
    },
}

-- Link this highlight group to make it more consistent with Telescope pickers, 
-- and to make it easier to see
local colors_group = vim.api.nvim_create_augroup('colors', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = colors_group,
    pattern = '*',
    callback = function() 
        vim.cmd('highlight link FloatBorder TelescopePromptBorder')
    end,
})

local illuminate_group = vim.api.nvim_create_augroup('illuminate_highlight', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = illuminate_group,
    pattern = '*',
    callback = function()
        vim.cmd('highlight IlluminatedWordText gui=underdot')
        vim.cmd('highlight IlluminatedWordRead gui=underdot')
        vim.cmd('highlight IlluminatedWordWrite gui=underdot')
    end,
})

require'illuminate'.configure{
    providers = {
        'lsp',
    },
}

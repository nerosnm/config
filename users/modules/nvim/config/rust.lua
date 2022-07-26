-- Turn on automatic formatting on save using nightly rustfmt
vim.g.rustfmt_command = 'rustfmt'
vim.g.rustfmt_autosave = 1

local id = vim.api.nvim_create_augroup('rust', {})
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    group = id,
    pattern = '*.lalrpop',
    callback = function()
        vim.opt_local.syntax = 'rust'
    end,
})

vim.cmd('highlight rustSelf ctermfg=38 guifg=#56B6C2 gui=italic')

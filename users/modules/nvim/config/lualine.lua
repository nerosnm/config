vim.opt.showmode = false

local onehalf = require'lualine.themes.onedark'

local colors = {
    fg = '#dcdfe4',
}

onehalf.normal.b.fg = colors.fg
onehalf.normal.c.fg = colors.fg

require'lualine'.setup {
    options = {
        theme = onehalf,
        component_separators = {
            left = '',
            right = '',
        },
        section_separators = {
            left = '',
            right = '',
        },
    },
    sections = {
        lualine_a = {
            'mode',
        },
        lualine_b = {
            {
                'filename',
                path = 1,
            },
        },
        lualine_c = {
            'diff',
            {
                'diagnostics',
                symbols = {
                    error = '☣ ',
                    warn = '☢ ',
                    info = '❄ ',
                    hint = '⚙ ',
                },
            },
            --             {
            --                 treelocation,
            --                 cond = treelocation_available,
            --             }
        },
        lualine_x = {
            'encoding',
            {
                'fileformat',
                symbols = {
                    unix = 'lf',
                    dos = 'crlf',
                    mac = 'cr',
                },
            },
            'filetype',
        },
        lualine_y = {
            'branch',
        },
        lualine_z = {
            'progress',
            'location',
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            {
                'filename',
                path = 1,
            },
        },
        lualine_x = {
            'location',
        },
        lualine_y = {},
        lualine_z = {}
    },
}

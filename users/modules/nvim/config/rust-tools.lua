local cmp_lsp = require'cmp_nvim_lsp'
local capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Run the plugin setup function
require('rust-tools').setup({
    tools = {
        inlay_hints = {
            parameter_hints_prefix = "› ",
            other_hints_prefix = "» ",
        }
    },

    server = {
        capabilities = capabilities,
        settings = {
            ["rust-analyzer"] = {
                diagnostics = {
                    disabled = {
                        "unresolved-proc-macro",
                    }
                },
                completion = {
                    postfix = {
                        enable = false,
                    },
                },
            },
        },
    },
})

local nvim_version = vim.version()
local nvim_version_str = string.format("nvim %d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)

local nixos_version_cmd = io.popen('nixos-version --json | jq -r .nixosVersion')
local nixos_version_raw = nixos_version_cmd:read('*all')
nixos_version_cmd:close()

local nixos_version_str = nixos_version_raw:match("^(%d+%.%d+).*")

local nvim_str = string.format("%s on NixOS %s", nvim_version_str, nixos_version_str)

require'presence':setup({
    neovim_image_text = nvim_str,
    enable_line_number = false,
    buttons = false,

    editing_text = function(filename)
        -- Determine type of file using vim's &filetype variable
        local filetype = vim.bo.filetype:gsub('^%l', string.upper)
        if filetype:sub(1, 1) == "A" then
            return string.format("Editing an %s file", filetype)
        else
            return string.format("Editing a %s file", filetype)
        end
    end,
    file_explorer_text = "Browsing files",
    reading_text = function(filename)
        -- Determine type of file using vim's &filetype variable
        local filetype = vim.bo.filetype:gsub('^%l', string.upper)
        if filetype:sub(1, 1) == "A" then
            return string.format("Reading an %s file", filetype)
        else
            return string.format("Reading a %s file", filetype)
        end
    end,
})

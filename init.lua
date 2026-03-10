-- Suppress lspconfig deprecation warning (lspconfig still works in nvim 0.11)
local original_deprecate = vim.deprecate
vim.deprecate = function(name, alternative, version, plugin, backtrace)
    if plugin == "nvim-lspconfig" then
        return  -- Suppress lspconfig warnings
    end
    return original_deprecate(name, alternative, version, plugin, backtrace)
end

-- Suppress position_encoding deprecation warning (plugins not yet updated for nvim 0.11)
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
    if type(msg) == "string" and msg:match("position_encoding param is required") then
        return  -- Suppress this deprecation notice
    end
    return original_notify(msg, level, opts)
end

require("core.settings")
require("core.keymaps")
require("core.lazy")
require("core.autocommand").setup()

require("keybinding")

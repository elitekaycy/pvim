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
local original_notify_once = vim.notify_once
local function should_suppress(msg)
    return type(msg) == "string" and msg:match("position_encoding param is required")
end
vim.notify = function(msg, level, opts)
    if should_suppress(msg) then return end
    return original_notify(msg, level, opts)
end
vim.notify_once = function(msg, level, opts)
    if should_suppress(msg) then return end
    return original_notify_once(msg, level, opts)
end

require("core.settings")
require("core.keymaps")
require("core.lazy")
require("core.autocommand").setup()

require("keybinding")

-- Start server for remote theme switching (theme switcher uses this)
local server_addr = vim.env.NVIM_LISTEN_ADDRESS
if not server_addr then
    local socket_path = "/tmp/pvim-" .. vim.fn.getpid()
    pcall(vim.fn.serverstart, socket_path)
end

local M = {}

local function open_pvim_readme()
    local readme = vim.fn.stdpath("config") .. "/readme.md"
    if vim.fn.filereadable(readme) == 0 then
        vim.notify("pvim README not found: " .. readme, vim.log.levels.ERROR)
        return false
    end

    vim.cmd("tabnew")
    vim.cmd("edit " .. vim.fn.fnameescape(readme))
    vim.bo.readonly = true
    vim.bo.modifiable = false
    vim.cmd("normal! gg")
    return true
end

local function search_readme(default_text)
    local ok_lazy, lazy = pcall(require, "lazy")
    if ok_lazy then
        pcall(lazy.load, { plugins = { "telescope.nvim" } })
    end

    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
        vim.notify("Telescope not available. Use / to search inside the README.", vim.log.levels.WARN)
        return
    end

    builtin.current_buffer_fuzzy_find({
        prompt_title = "pvim quick reference",
        default_text = default_text ~= "" and default_text or nil,
    })
end

function M.setup()
    vim.api.nvim_create_user_command("PvimSource", function(opts)
        if open_pvim_readme() then
            vim.schedule(function()
                search_readme(opts.args or "")
            end)
        end
    end, {
        nargs = "*",
        desc = "Open and search the pvim quick reference",
    })

    vim.api.nvim_create_user_command("PvimKeys", function(opts)
        vim.cmd("PvimSource " .. (opts.args or ""))
    end, {
        nargs = "*",
        desc = "Alias for :PvimSource",
    })

    vim.cmd([[
      cnoreabbrev <expr> pvimsource ((getcmdtype() == ':' && getcmdline() ==# 'pvimsource') ? 'PvimSource' : 'pvimsource')
      cnoreabbrev <expr> pvimkeys ((getcmdtype() == ':' && getcmdline() ==# 'pvimkeys') ? 'PvimKeys' : 'pvimkeys')
    ]])
end

return M

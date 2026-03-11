local M = {}

local codelens_group = vim.api.nvim_create_augroup("PvimCodeLens", { clear = true })

-- Debounce state
local debounce_timer = nil
local last_refresh = 0
local DEBOUNCE_MS = 500  -- Minimum time between refreshes

-- Filetypes that support codelens
local CODELENS_FILETYPES = {
    java = true,
    typescript = true,
    typescriptreact = true,
    javascript = true,
    go = true,
    rust = true,
}

function M.setup_codelens()
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = codelens_group,
        callback = function()
            -- Skip unsupported filetypes
            local ft = vim.bo.filetype
            if not CODELENS_FILETYPES[ft] then
                return
            end

            -- Debounce: skip if we refreshed recently
            local now = vim.loop.now()
            if now - last_refresh < DEBOUNCE_MS then
                return
            end

            -- Cancel pending timer
            if debounce_timer then
                vim.fn.timer_stop(debounce_timer)
                debounce_timer = nil
            end

            -- Debounced refresh
            debounce_timer = vim.fn.timer_start(100, function()
                debounce_timer = nil
                last_refresh = vim.loop.now()
                vim.schedule(function()
                    -- Check if buffer still valid and has LSP
                    local clients = vim.lsp.get_clients({ bufnr = 0 })
                    local has_codelens = false
                    for _, client in ipairs(clients) do
                        if client.supports_method('textDocument/codeLens') then
                            has_codelens = true
                            break
                        end
                    end

                    if has_codelens then
                        vim.lsp.codelens.refresh()
                    end

                    -- Lightbulb (only if installed)
                    local ok, lightbulb = pcall(require, 'nvim-lightbulb')
                    if ok then
                        lightbulb.update_lightbulb {
                            sign = {
                                enabled = true,
                                priority = 10,
                            },
                            virtual_text = {
                                enabled = true,
                                text = "💡",
                            },
                            float = {
                                enabled = false,  -- Disable float to reduce noise
                            },
                        }
                    end
                end)
            end)
        end
    })

    vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run,
        { noremap = true, silent = true, desc = 'Run CodeLens action' })
end

function M.on_attach(client, bufnr)
    if client.supports_method('textDocument/codeLens') then
        M.setup_codelens()
    end
end

return M

local M = {}

function M.setup_codelens()
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        callback = function()
            vim.lsp.codelens.refresh()
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
                        enabled = true,
                    },
                }
            end
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

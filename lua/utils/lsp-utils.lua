local M = {}

M.ensure_lsp_ready = function()
    -- Check if the LSP server is ready
    if not vim.lsp.buf.server_ready() then
        vim.lsp.start_client() -- Start the LSP client if not already running
    end

    -- Wait for the server to be ready (blocking for a short period)
    local timeout = 5000 -- milliseconds
    vim.wait(timeout, vim.lsp.buf.server_ready, 100)

    -- Return whether the server is ready
    return vim.lsp.buf.server_ready()
end

return M

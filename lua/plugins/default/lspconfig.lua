return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    -- Note: deprecation warning is expected in nvim 0.11+, lspconfig still works
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local lsp_servers_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"
        for _, file in ipairs(vim.fn.readdir(lsp_servers_dir)) do
            if file:match("%.lua$") then
                local module_name = file:gsub("%.lua$", "")
                require("plugins.lsp.servers." .. module_name)
            end
        end

    end,
}

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "mfussenegger/nvim-jdtls",
        'ray-x/lsp_signature.nvim',
        'kosayoda/nvim-lightbulb',
    },
    config = function()
        -- require("plugins.lsp.servers.typescript")
        -- require("plugins.lsp.servers.java")
        -- require("plugins.lsp.servers.lua")

        local lsp_servers_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"
        for _, file in ipairs(vim.fn.readdir(lsp_servers_dir)) do
            if file:match("%.lua$") then
                local module_name = file:gsub("%.lua$", "")
                require("plugins.lsp.servers." .. module_name)
            end
        end
    end,
}

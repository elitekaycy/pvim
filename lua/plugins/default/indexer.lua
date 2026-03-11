-- Project Indexer plugin
-- Provides intelligent code suggestions based on project-wide symbol analysis
return {
    dir = vim.fn.stdpath("config") .. "/lua/indexer",
    name = "pvim-indexer",
    dependencies = {
        "kkharji/sqlite.lua",
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
    },
    ft = { "java", "typescript", "typescriptreact", "javascript", "javascriptreact" },
    cmd = { "IndexProject", "IndexFile", "IndexStatus" },
    config = function()
        local indexer = require("indexer")
        indexer.setup({
            enabled = true,
            languages = { "java", "typescript", "javascript" },
            cache_dir = vim.fn.stdpath("cache") .. "/pvim/index",
            auto_index = true,
            git_aware = true,
        })
    end,
}

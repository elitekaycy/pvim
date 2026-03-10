return {
    -- Comment toggling
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",
        },
        config = function()
            require("Comment").setup({
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            })
        end,
    },

    -- Context-aware commentstring (for JSX, Vue, etc.)
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
        opts = {
            enable_autocmd = false,
        },
    },

    -- Documentation generation
    {
        "danymat/neogen",
        dependencies = "nvim-treesitter/nvim-treesitter",
        cmd = "Neogen",
        keys = {
            { "<leader>nf", function() require("neogen").generate({ type = "func" }) end, desc = "Generate function doc" },
            { "<leader>nc", function() require("neogen").generate({ type = "class" }) end, desc = "Generate class doc" },
            { "<leader>nt", function() require("neogen").generate({ type = "type" }) end, desc = "Generate type doc" },
            { "<leader>nF", function() require("neogen").generate({ type = "file" }) end, desc = "Generate file doc" },
        },
        opts = {
            snippet_engine = "luasnip",
            languages = {
                lua = { template = { annotation_convention = "ldoc" } },
                python = { template = { annotation_convention = "google_docstrings" } },
                javascript = { template = { annotation_convention = "jsdoc" } },
                typescript = { template = { annotation_convention = "tsdoc" } },
                typescriptreact = { template = { annotation_convention = "tsdoc" } },
                javascriptreact = { template = { annotation_convention = "jsdoc" } },
                java = { template = { annotation_convention = "javadoc" } },
                c = { template = { annotation_convention = "doxygen" } },
                cpp = { template = { annotation_convention = "doxygen" } },
                rust = { template = { annotation_convention = "rustdoc" } },
                go = { template = { annotation_convention = "godoc" } },
            },
        },
    },
}

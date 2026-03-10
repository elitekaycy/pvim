return {
    "ahmedkhalf/project.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
        require("project_nvim").setup({
            detection_methods = { "pattern", "lsp" },
            patterns = {
                ".git",
                "Makefile",
                "package.json",
                "pom.xml",
                "build.gradle",
                "build.gradle.kts",
                "Cargo.toml",
                "go.mod",
            },
            silent_chdir = true,
            show_hidden = false,
            scope_chdir = "global",
            datapath = vim.fn.stdpath("data"),
            exclude_dirs = { "~/.cargo/*", "*/node_modules/*" },
        })

        -- Lazy load telescope extension
        vim.defer_fn(function()
            pcall(function() require("telescope").load_extension("projects") end)
        end, 100)

        vim.keymap.set("n", "<leader>fp", ":Telescope projects<CR>", { desc = "Find Projects", silent = true })
    end,
}

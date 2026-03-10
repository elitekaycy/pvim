return {
    "ahmedkhalf/project.nvim",
    config = function()
        require("project_nvim").setup({
            -- Detection methods: "lsp", "pattern", or both
            detection_methods = { "pattern", "lsp" },

            -- Patterns to detect project root
            patterns = {
                ".git",
                "_darcs",
                ".hg",
                ".bzr",
                ".svn",
                "Makefile",
                "package.json",
                "pom.xml",
                "build.gradle",
                "build.gradle.kts",
                "Cargo.toml",
                "go.mod",
                "pyproject.toml",
                "setup.py",
                "requirements.txt",
            },

            -- Don't change directory when opening a file
            silent_chdir = true,

            -- Show hidden files in telescope
            show_hidden = true,

            -- Scope for changing directory
            scope_chdir = "global",

            -- Path to store project history
            datapath = vim.fn.stdpath("data"),
        })

        -- Load telescope extension
        require("telescope").load_extension("projects")

        -- Keybinding for quick project access
        vim.keymap.set("n", "<leader>fp", ":Telescope projects<CR>", { desc = "Find Projects", silent = true })
    end,
}

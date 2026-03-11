-- Project Management
-- Quick switch between projects with Telescope
return {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
        require("project_nvim").setup({
            -- Detection methods: "lsp", "pattern"
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
                "Cargo.toml",
                "go.mod",
                "pyproject.toml",
                "requirements.txt",
            },

            -- Don't auto-change directory
            silent_chdir = true,

            -- Scope for changing directory
            scope_chdir = "global",

            -- Path to store project history
            datapath = vim.fn.stdpath("data"),
        })

        -- Telescope integration
        local ok, telescope = pcall(require, "telescope")
        if ok then
            telescope.load_extension("projects")
        end
    end,
    keys = {
        { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find projects" },
    },
}

-- Refactoring
-- Extract function/variable, inline, and more
return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "Refactor" },
    keys = {
        -- Extract (visual mode)
        {
            "<leader>re",
            function()
                require("refactoring").refactor("Extract Function")
            end,
            mode = "x",
            desc = "Extract function",
        },
        {
            "<leader>rf",
            function()
                require("refactoring").refactor("Extract Function To File")
            end,
            mode = "x",
            desc = "Extract function to file",
        },
        {
            "<leader>rv",
            function()
                require("refactoring").refactor("Extract Variable")
            end,
            mode = "x",
            desc = "Extract variable",
        },

        -- Inline (both modes)
        {
            "<leader>ri",
            function()
                require("refactoring").refactor("Inline Variable")
            end,
            mode = { "n", "x" },
            desc = "Inline variable",
        },

        -- Extract block (normal mode)
        {
            "<leader>rb",
            function()
                require("refactoring").refactor("Extract Block")
            end,
            desc = "Extract block",
        },
        {
            "<leader>rB",
            function()
                require("refactoring").refactor("Extract Block To File")
            end,
            desc = "Extract block to file",
        },

        -- Refactor menu (Telescope)
        {
            "<leader>rr",
            function()
                require("refactoring").select_refactor()
            end,
            mode = { "n", "x" },
            desc = "Refactor menu",
        },

        -- Debug: print variable
        {
            "<leader>rp",
            function()
                require("refactoring").debug.printf({ below = false })
            end,
            desc = "Debug print",
        },
        {
            "<leader>rP",
            function()
                require("refactoring").debug.print_var()
            end,
            mode = { "n", "x" },
            desc = "Debug print variable",
        },
        {
            "<leader>rc",
            function()
                require("refactoring").debug.cleanup({})
            end,
            desc = "Debug cleanup",
        },
    },
    opts = {
        prompt_func_return_type = {
            go = true,
            java = true,
            cpp = true,
            c = true,
        },
        prompt_func_param_type = {
            go = true,
            java = true,
            cpp = true,
            c = true,
        },
        printf_statements = {},
        print_var_statements = {},
        show_success_message = true,
    },
    config = function(_, opts)
        require("refactoring").setup(opts)

        -- Load Telescope extension
        local ok, telescope = pcall(require, "telescope")
        if ok then
            telescope.load_extension("refactoring")
        end
    end,
}

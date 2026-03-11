-- Neotest
-- Modern test runner with nice UI
return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        -- Test adapters
        "rcasia/neotest-java",
        "nvim-neotest/neotest-jest",
        "marilari88/neotest-vitest",
        "nvim-neotest/neotest-go",
        "nvim-neotest/neotest-python",
    },
    cmd = { "Neotest" },
    keys = {
        { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
        { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run all tests" },
        { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
        { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show test output" },
        { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
        { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop test" },
        { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Watch file tests" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
        { "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
        { "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-java")({
                    ignore_wrapper = false,
                }),
                require("neotest-jest")({
                    jestCommand = "npm test --",
                    jestConfigFile = "jest.config.js",
                    env = { CI = true },
                    cwd = function()
                        return vim.fn.getcwd()
                    end,
                }),
                require("neotest-vitest"),
                require("neotest-go"),
                require("neotest-python")({
                    dap = { justMyCode = false },
                }),
            },
            status = {
                virtual_text = true,
                signs = true,
            },
            output = {
                enabled = true,
                open_on_run = "short",
            },
            quickfix = {
                enabled = true,
                open = false,
            },
            icons = {
                passed = "✓",
                failed = "✗",
                running = "⟳",
                skipped = "○",
                unknown = "?",
            },
            floating = {
                border = "rounded",
                max_height = 0.6,
                max_width = 0.6,
            },
            summary = {
                mappings = {
                    expand = { "<CR>", "<2-LeftMouse>" },
                    expand_all = "e",
                    output = "o",
                    short = "O",
                    attach = "a",
                    jumpto = "i",
                    stop = "u",
                    run = "r",
                    debug = "d",
                    mark = "m",
                    run_marked = "R",
                    debug_marked = "D",
                    clear_marked = "M",
                },
            },
        })
    end,
}

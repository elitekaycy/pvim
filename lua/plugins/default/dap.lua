return {
    'mfussenegger/nvim-dap',
    keys = {
        { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue" },
        { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
        { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
        { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
        { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
        {
            "<leader>B",
            function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
            desc = "Debug: Conditional Breakpoint"
        },
        { "<leader>dc", function() require("dap").continue() end, desc = "Debug: Continue" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Debug: Step Into" },
        { "<leader>do", function() require("dap").step_over() end, desc = "Debug: Step Over" },
        { "<leader>dO", function() require("dap").step_out() end, desc = "Debug: Step Out" },
        { "<leader>dq", function() require("dap").terminate() end, desc = "Debug: Terminate" },
        { "<leader>dr", function() require("dap").restart() end, desc = "Debug: Restart" },
        { "<leader>dp", function() require("dap").pause() end, desc = "Debug: Pause" },
        { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
        { "<leader>de", function() require("dapui").eval() end, mode = "n", desc = "Debug: Evaluate" },
        { "<leader>de", function() require("dapui").eval() end, mode = "v", desc = "Debug: Evaluate Selection" },
        {
            "<leader>dB",
            function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
            desc = "Debug: Log Point"
        },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
        { "<leader>dC", function() require("dap").clear_breakpoints() end, desc = "Debug: Clear Breakpoints" },
    },
    dependencies = {
        'nvim-neotest/nvim-nio',
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
        'williamboman/mason.nvim',
    },
    config = function()
        local lsp_debuggers_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/debuggers"
        for _, file in ipairs(vim.fn.readdir(lsp_debuggers_dir)) do
            if file:match("%.lua$") then
                local module_name = file:gsub("%.lua$", "")
                require("plugins.lsp.debuggers." .. module_name)
            end
        end

        require('dapui').setup({
            icons = { expanded = "▾", collapsed = "▸" },
            mappings = {
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t"
            },
            layouts = {
                {
                    elements = {
                        { id = "scopes",      type = "trees" },
                        { id = "breakpoints", type = "trees" },
                        { id = "stacks",      type = "trees" },
                        { id = "watches",     type = "trees" }
                    },
                    size = 40,
                    position = "left"
                },
                {
                    elements = { "repl", "console" },
                    size = 10,
                    position = "bottom"
                }
            }
        })



        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end


        -- Debug keybindings
        vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
        vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
        vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
        vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>B", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, { desc = "Debug: Conditional Breakpoint" })

        -- Additional debug controls
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Continue" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
        vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug: Step Over" })
        vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug: Step Out" })
        vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: Terminate" })
        vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "Debug: Restart" })
        vim.keymap.set("n", "<leader>dp", dap.pause, { desc = "Debug: Pause" })

        -- DAP UI controls
        vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
        vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "Debug: Evaluate" })
        vim.keymap.set("v", "<leader>de", dapui.eval, { desc = "Debug: Evaluate Selection" })

        -- Breakpoint management
        vim.keymap.set("n", "<leader>dB", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end, { desc = "Debug: Log Point" })
        vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
        vim.keymap.set("n", "<leader>dC", dap.clear_breakpoints, { desc = "Debug: Clear Breakpoints" })


        require("nvim-dap-virtual-text").setup {
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = true,
            show_stop_reason = true,
            commented = false,
            only_first_definition = true,
            display_callback = function(variable)
                return variable.name .. ' = ' .. variable.value
            end
        }
    end,
}

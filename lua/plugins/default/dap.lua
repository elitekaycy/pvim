return {
    'mfussenegger/nvim-dap',
    dependencies = {
        'nvim-neotest/nvim-nio',
        'rcarriga/nvim-dap-ui',
        'theHamsta/nvim-dap-virtual-text',
        'williamboman/mason.nvim',
        'leoluz/nvim-dap-go',
        'mfussenegger/nvim-dap-python' },
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


        vim.keymap.set('n', '<F5>', dap.continue)
        vim.keymap.set('n', '<F10>', dap.step_over)
        vim.keymap.set('n', '<F11>', dap.step_into)
        vim.keymap.set('n', '<F12>', dap.step_out)
        vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint)
        vim.keymap.set('n', '<leader>B', function()
            dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end)


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

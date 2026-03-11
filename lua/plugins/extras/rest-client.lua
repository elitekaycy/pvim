-- REST Client (kulala.nvim)
-- Test APIs directly in Neovim with .http files
return {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
        { "<leader>rs", desc = "Send request" },
        { "<leader>ra", desc = "Send all requests" },
        { "<leader>rp", desc = "Preview request" },
        { "<leader>ri", desc = "Inspect response" },
        { "<leader>rc", desc = "Copy as cURL" },
        { "<leader>rt", desc = "Toggle response view" },
        { "<leader>re", desc = "Set environment" },
        { "<leader>rh", desc = "Request history" },
    },
    opts = {
        -- Default split direction for response
        split_direction = "vertical",
        -- Default protocol (http or https)
        default_view = "body",
        -- Environment file name
        environment_scope = "b",  -- buffer local
    },
    config = function(_, opts)
        local kulala = require("kulala")
        kulala.setup(opts)

        -- Keymaps
        vim.keymap.set("n", "<leader>rs", kulala.run, { desc = "Send HTTP request" })
        vim.keymap.set("n", "<leader>ra", kulala.run_all, { desc = "Send all requests" })
        vim.keymap.set("n", "<leader>rp", kulala.replay, { desc = "Replay last request" })
        vim.keymap.set("n", "<leader>ri", kulala.inspect, { desc = "Inspect response" })
        vim.keymap.set("n", "<leader>rc", kulala.copy, { desc = "Copy as cURL" })
        vim.keymap.set("n", "<leader>rt", kulala.toggle_view, { desc = "Toggle body/headers" })
        vim.keymap.set("n", "<leader>re", kulala.set_selected_env, { desc = "Set environment" })
        vim.keymap.set("n", "[r", kulala.jump_prev, { desc = "Previous request" })
        vim.keymap.set("n", "]r", kulala.jump_next, { desc = "Next request" })

        -- Create HTTP filetype detection
        vim.filetype.add({
            extension = {
                http = "http",
                rest = "http",
            },
        })

        -- User commands
        vim.api.nvim_create_user_command("RestRun", function()
            kulala.run()
        end, { desc = "Run HTTP request under cursor" })

        vim.api.nvim_create_user_command("RestRunAll", function()
            kulala.run_all()
        end, { desc = "Run all HTTP requests in file" })

        vim.api.nvim_create_user_command("RestCopy", function()
            kulala.copy()
        end, { desc = "Copy request as cURL" })

        vim.api.nvim_create_user_command("RestEnv", function()
            kulala.set_selected_env()
        end, { desc = "Set environment" })
    end,
}

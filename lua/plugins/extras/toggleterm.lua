-- Toggleterm
-- Floating terminal with easy toggle
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
        { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
        { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal size=15<cr>", desc = "Horizontal terminal" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical terminal" },
        { "<leader>t1", "<cmd>1ToggleTerm<cr>", desc = "Terminal 1" },
        { "<leader>t2", "<cmd>2ToggleTerm<cr>", desc = "Terminal 2" },
        { "<leader>t3", "<cmd>3ToggleTerm<cr>", desc = "Terminal 3" },
    },
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
            end
        end,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
            border = "curved",
            width = function()
                return math.floor(vim.o.columns * 0.8)
            end,
            height = function()
                return math.floor(vim.o.lines * 0.8)
            end,
            winblend = 0,
        },
        winbar = {
            enabled = false,
        },
    },
    config = function(_, opts)
        require("toggleterm").setup(opts)

        -- Terminal mode mappings
        function _G.set_terminal_keymaps()
            local keymap_opts = { buffer = 0 }
            vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], keymap_opts)
            vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], keymap_opts)
            vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], keymap_opts)
            vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], keymap_opts)
            vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], keymap_opts)
        end

        vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

        -- Custom terminals
        local Terminal = require("toggleterm.terminal").Terminal

        -- Lazygit (if not using lazygit.nvim)
        local lazygit = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = {
                border = "curved",
            },
            on_open = function(term)
                vim.cmd("startinsert!")
            end,
        })

        vim.keymap.set("n", "<leader>tg", function()
            lazygit:toggle()
        end, { desc = "Lazygit (toggleterm)" })

        -- Node REPL
        local node = Terminal:new({
            cmd = "node",
            direction = "float",
        })

        vim.keymap.set("n", "<leader>tn", function()
            node:toggle()
        end, { desc = "Node REPL" })

        -- Python REPL
        local python = Terminal:new({
            cmd = "python3",
            direction = "float",
        })

        vim.keymap.set("n", "<leader>tp", function()
            python:toggle()
        end, { desc = "Python REPL" })
    end,
}

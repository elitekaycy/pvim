-- Aerial
-- Code outline / symbols sidebar
return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
        { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Toggle outline" },
        { "<leader>O", "<cmd>AerialNavToggle<cr>", desc = "Toggle outline nav" },
        { "{", "<cmd>AerialPrev<cr>", desc = "Prev symbol" },
        { "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
    },
    opts = {
        -- Backend priority
        backends = { "treesitter", "lsp", "markdown", "man" },

        -- Layout
        layout = {
            max_width = { 40, 0.2 },
            min_width = 20,
            default_direction = "prefer_right",
            placement = "edge",
            resize_to_content = true,
            preserve_equality = false,
        },

        -- Attach behavior
        attach_mode = "global",
        close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },

        -- Keymaps in aerial window
        keymaps = {
            ["?"] = "actions.show_help",
            ["g?"] = "actions.show_help",
            ["<CR>"] = "actions.jump",
            ["<2-LeftMouse>"] = "actions.jump",
            ["<C-v>"] = "actions.jump_vsplit",
            ["<C-s>"] = "actions.jump_split",
            ["p"] = "actions.scroll",
            ["<C-j>"] = "actions.down_and_scroll",
            ["<C-k>"] = "actions.up_and_scroll",
            ["{"] = "actions.prev",
            ["}"] = "actions.next",
            ["[["] = "actions.prev_up",
            ["]]"] = "actions.next_up",
            ["q"] = "actions.close",
            ["o"] = "actions.tree_toggle",
            ["za"] = "actions.tree_toggle",
            ["O"] = "actions.tree_toggle_recursive",
            ["zA"] = "actions.tree_toggle_recursive",
            ["l"] = "actions.tree_open",
            ["zo"] = "actions.tree_open",
            ["L"] = "actions.tree_open_recursive",
            ["zO"] = "actions.tree_open_recursive",
            ["h"] = "actions.tree_close",
            ["zc"] = "actions.tree_close",
            ["H"] = "actions.tree_close_recursive",
            ["zC"] = "actions.tree_close_recursive",
            ["zr"] = "actions.tree_increase_fold_level",
            ["zR"] = "actions.tree_open_all",
            ["zm"] = "actions.tree_decrease_fold_level",
            ["zM"] = "actions.tree_close_all",
            ["zx"] = "actions.tree_sync_folds",
            ["zX"] = "actions.tree_sync_folds",
        },

        -- Filtering
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Module",
            "Method",
            "Struct",
            "Variable",
            "Constant",
            "Field",
            "Property",
        },

        -- Highlight
        highlight_mode = "split_width",
        highlight_closest = true,
        highlight_on_hover = true,
        highlight_on_jump = 300,

        -- Icons
        icons = {},

        -- Show guides
        show_guides = true,
        guides = {
            mid_item = "├─",
            last_item = "└─",
            nested_top = "│ ",
            whitespace = "  ",
        },

        -- Float preview
        float = {
            border = "rounded",
            relative = "cursor",
            max_height = 0.9,
            min_height = { 8, 0.1 },
        },

        -- Nav window
        nav = {
            border = "rounded",
            max_height = 0.9,
            min_height = { 10, 0.1 },
            max_width = 0.5,
            min_width = { 0.2, 20 },
            win_opts = {
                cursorline = true,
                winblend = 10,
            },
            autojump = false,
            preview = true,
            keymaps = {
                ["<CR>"] = "actions.jump",
                ["<2-LeftMouse>"] = "actions.jump",
                ["<C-v>"] = "actions.jump_vsplit",
                ["<C-s>"] = "actions.jump_split",
                ["h"] = "actions.left",
                ["l"] = "actions.right",
                ["<C-c>"] = "actions.close",
            },
        },

        -- Lualine integration
        lualine_all_symbols = true,
    },
    config = function(_, opts)
        require("aerial").setup(opts)

        -- Telescope integration
        local ok, telescope = pcall(require, "telescope")
        if ok then
            telescope.load_extension("aerial")
        end
    end,
}

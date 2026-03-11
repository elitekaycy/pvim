-- Spectre
-- Project-wide search and replace
return {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Spectre" },
    keys = {
        { "<leader>sr", function() require("spectre").toggle() end, desc = "Search & Replace (Spectre)" },
        { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" },
        { "<leader>sf", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search in current file" },
        { "<leader>sr", function() require("spectre").open_visual() end, mode = "v", desc = "Search selection" },
    },
    opts = {
        open_cmd = "vnew",
        live_update = true,
        is_insert_mode = false,
        mapping = {
            ["toggle_line"] = {
                map = "dd",
                cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
                desc = "toggle item",
            },
            ["enter_file"] = {
                map = "<cr>",
                cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
                desc = "open file",
            },
            ["send_to_qf"] = {
                map = "<leader>q",
                cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                desc = "send to quickfix",
            },
            ["replace_cmd"] = {
                map = "<leader>c",
                cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
                desc = "input replace command",
            },
            ["show_option_menu"] = {
                map = "<leader>o",
                cmd = "<cmd>lua require('spectre').show_options()<CR>",
                desc = "show options",
            },
            ["run_current_replace"] = {
                map = "<leader>rc",
                cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
                desc = "replace current line",
            },
            ["run_replace"] = {
                map = "<leader>R",
                cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                desc = "replace all",
            },
        },
    },
}

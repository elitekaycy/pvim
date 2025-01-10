return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    config = function()
        require("noice").setup({
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            cmdline = {
                format = {
                    cmdline = {
                        pattern = "^Create file",
                        icon = "󰙅",
                        lang = "message",
                        opts = {
                            format = function(message)
                                return message:gsub("^%[nvim%-tree%]%s*(.-)%s+[/\\].*$", "%1")
                            end,
                        },
                    },
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = false,
            },
        })
    end,
}

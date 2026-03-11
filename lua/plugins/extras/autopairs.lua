-- Auto Pairs
-- Automatically close brackets, quotes, etc.
return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
    opts = {
        check_ts = true,
        ts_config = {
            lua = { "string", "source" },
            javascript = { "string", "template_string" },
            java = false,
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
            map = "<M-e>",
            chars = { "{", "[", "(", '"', "'" },
            pattern = [=[[%'%"%)%>%]%)%}%,]]=],
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "Search",
            highlight_grey = "Comment",
        },
        enable_check_bracket_line = true,
        enable_bracket_in_quote = true,
        enable_abbr = false,
        break_undo = true,
        map_cr = true,
        map_bs = true,
        map_c_h = false,
        map_c_w = false,
    },
    config = function(_, opts)
        local autopairs = require("nvim-autopairs")
        autopairs.setup(opts)

        -- Integration with nvim-cmp
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

        -- Custom rules
        local Rule = require("nvim-autopairs.rule")
        local cond = require("nvim-autopairs.conds")

        -- Add spaces between parentheses
        autopairs.add_rules({
            Rule(" ", " ")
                :with_pair(function(rule_opts)
                    local pair = rule_opts.line:sub(rule_opts.col - 1, rule_opts.col)
                    return vim.tbl_contains({ "()", "[]", "{}" }, pair)
                end)
                :with_move(cond.none())
                :with_cr(cond.none())
                :with_del(function(rule_opts)
                    local col = vim.api.nvim_win_get_cursor(0)[2]
                    local context = rule_opts.line:sub(col - 1, col + 2)
                    return vim.tbl_contains({ "(  )", "[  ]", "{  }" }, context)
                end),
        })

        -- Arrow function for JavaScript/TypeScript
        autopairs.add_rules({
            Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript", "javascriptreact" })
                :use_regex(true)
                :set_end_pair_length(2),
        })
    end,
}

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            svelte = { "eslint_d" },
        }

        local function can_lint(bufnr)
            local ft = vim.bo[bufnr].filetype
            local names = lint.linters_by_ft[ft]
            if not names or #names == 0 then
                return false
            end

            for _, name in ipairs(names) do
                local linter = lint.linters[name]
                local cmd = linter and linter.cmd
                if type(cmd) == "function" then
                    cmd = cmd()
                end
                if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
                    return true
                end
            end

            return false
        end

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function(ev)
                if not can_lint(ev.buf) then
                    return
                end
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>l", function()
            if not can_lint(0) then
                vim.notify("No available linter for this buffer", vim.log.levels.INFO)
                return
            end
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}

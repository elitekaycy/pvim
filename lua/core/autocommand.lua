local M = {}

function M.setup()
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank({
                higroup = "YankHighlight",
                timeout = 200,
            })
        end,
    })

    vim.cmd([[
    highlight YankHighlight guibg=#ffcc00 guifg=#000000

    highlight Visual guibg=#5555FF guifg=#FFFFFF
  ]])
end

return M

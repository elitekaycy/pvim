-- UFO (Ultra Fold)
-- Modern folding with preview
return {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    event = "BufReadPost",
    keys = {
        { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open folds except kinds" },
        { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close folds with" },
        { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
    init = function()
        -- Required for ufo
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
    end,
    opts = {
        -- Provider selection
        provider_selector = function(bufnr, filetype, buftype)
            -- Use treesitter and indent as fallback
            return { "treesitter", "indent" }
        end,

        -- Open fold when entering
        open_fold_hl_timeout = 150,

        -- Close fold kinds (will not be opened with zr)
        close_fold_kinds_for_ft = {
            default = { "imports", "comment" },
            json = { "array" },
            c = { "comment", "region" },
        },

        -- Preview window config
        preview = {
            win_config = {
                border = { "", "─", "", "", "", "─", "", "" },
                winhighlight = "Normal:Folded",
                winblend = 0,
            },
            mappings = {
                scrollU = "<C-u>",
                scrollD = "<C-d>",
                jumpTop = "[",
                jumpBot = "]",
            },
        },

        -- Custom fold text
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = (" 󰁂 %d "):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0

            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end

            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end,

        -- Enable fold kinds
        enable_get_fold_virt_text = true,
    },
    config = function(_, opts)
        require("ufo").setup(opts)

        -- Optional: Customize statuscolumn for fold indicators
        -- vim.opt.statuscolumn = "%s%l %C"
    end,
}

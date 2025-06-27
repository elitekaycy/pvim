-- return {
-- 	"rebelot/kanagawa.nvim",
-- 	config = function()
-- 		require("kanagawa").setup()
-- 		vim.cmd("colorscheme kanagawa")
-- 	end,
-- }
--
return {
    "rebelot/kanagawa.nvim",
    config = function()
        require("kanagawa").setup({
            transparent = true, -- this disables the background color
        })
        vim.cmd("colorscheme kanagawa")

        -- Optional: make Normal and Float windows more see-through
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
}

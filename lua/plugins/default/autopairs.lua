return {
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true, -- Enable Tree-sitter integration
				disable_filetype = { "TelescopePrompt", "vim" }, -- Disable in specific filetypes
				fast_wrap = {
					map = "<M-e>", -- Keybinding to wrap existing text
					chars = { "{", "[", "(", '"', "'" },
					pattern = [=[[%'%"%>%]%)%}%,]]=],
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "Search",
					highlight_grey = "Comment",
				},
			})
		end,
	},
}

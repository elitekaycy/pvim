return {
	{
		"windwp/nvim-autopairs",
		enabled = false,
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				disable_filetype = { "TelescopePrompt", "vim" },
				fast_wrap = {
					map = "<M-e>",
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

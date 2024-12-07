return {
	"saadparwaiz1/cmp_luasnip",
	dependencies = {
		"L3MON4D3/LuaSnip",
	},
	config = function()
		local ls = require("luasnip")

		ls.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
		})

		require("luasnip.loaders.from_vscode").lazy_load()
	end,
}

return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("bufferline").setup({
			options = {
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						padding = 1,
					},
				},
				separator_style = "thin",
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_tab_indicators = true,
			},
		})
	end,
}

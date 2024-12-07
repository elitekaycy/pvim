return {
	"onsails/lspkind-nvim",
	config = function()
		require("lspkind").init({
			mode = "symbol_text",

			-- Choose the preset icons to use. You can use either 'default' or 'codicons'.
			-- 'codicons' is set here, but if you prefer 'default', you can switch it.
			preset = "codicons",

			-- Override symbols for various types in your LSP completions
			symbol_map = {
				Text = "󰉿", -- Text
				Method = "󰆧", -- Method
				Function = "󰊕", -- Function
				Constructor = "", -- Constructor
				Field = "󰜢", -- Field
				Variable = "󰀫", -- Variable
				Class = "󰠱", -- Class
				Interface = "", -- Interface
				Module = "", -- Module
				Property = "󰜢", -- Property
				Unit = "󰑭", -- Unit
				Value = "󰎠", -- Value
				Enum = "", -- Enum
				Keyword = "󰌋", -- Keyword
				Snippet = "", -- Snippet
				Color = "󰏘", -- Color
				File = "󰈙", -- File
				Reference = "󰈇", -- Reference
				Folder = "󰉋", -- Folder
				EnumMember = "", -- EnumMember
				Constant = "󰏿", -- Constant
				Struct = "󰙅", -- Struct
				Event = "", -- Event
				Operator = "󰆕", -- Operator
				TypeParameter = "", -- TypeParameter (empty as default, can be modified)
			},
		})
	end,
}

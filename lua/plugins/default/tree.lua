return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			disable_netrw = true,
			hijack_netrw = true,
			hijack_unnamed_buffer_when_opening = false,
			update_focused_file = {
				enable = false,
			},

			view = {
				side = "left",
				width = 30,
				centralize_selection = false,
				cursorline = true,
				number = false,
				relativenumber = false,
				signcolumn = "yes",
				float = {
					enable = false,
                },
			},

			renderer = {
				highlight_git = true,
				highlight_opened_files = "all",
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
						modified = true,
						hidden = true,
						diagnostics = true,
						bookmarks = true,
					},
					glyphs = {
						default = "",
						symlink = "",
						bookmark = "󰆤",
						modified = "●",
						hidden = "󰜌",
						folder = {
							arrow_closed = "",
							arrow_open = "",
							default = "",
							open = "",
							empty = "",
							empty_open = "",
							symlink = "",
							symlink_open = "",
						},
						git = {
							unstaged = "✗",
							staged = "✓",
							unmerged = "",
							renamed = "➜",
							untracked = "★",
							deleted = "",
							ignored = "◌",
						},
					},
				},
			},

			hijack_directories = {
				enable = true,
				auto_open = true,
			},

			actions = {
				open_file = {
					quit_on_open = false,
					resize_window = true,
					window_picker = {
						enable = true,
						picker = "default",
						chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
						exclude = {
							filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
							buftype = { "nofile", "terminal", "help" },
						},
					},
				},
			},

			trash = {
				cmd = "gio trash",
			},

			git = {
				enable = true,
				show_on_dirs = true,
				show_on_open_dirs = true,
			},

			diagnostics = {
				enable = true,
				show_on_dirs = true,
				debounce_delay = 500,
			},

			filters = {
				enable = true,
				git_ignored = true,
				dotfiles = false,
			},
		})
	end,
}

return {
	"nvim-tree/nvim-tree.lua", -- Plugin name
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- Dependency for file icons
	},
	config = function()
		-- Setting up nvim-tree with the required configurations
		require("nvim-tree").setup({
			-- Basic Settings
			disable_netrw = true, -- Disable netrw
			hijack_netrw = true, -- Hijack netrw for file management
			hijack_unnamed_buffer_when_opening = false, -- Prevent hijacking of unnamed buffers
			update_focused_file = {
				enable = false, -- Disable updating of focused file
			},

			-- View Settings
			view = {
				side = "right", -- Position the tree on the right
				width = 30, -- Set width of the tree window
				centralize_selection = false, -- Do not centralize selection
				cursorline = true, -- Highlight the line under cursor
				number = false, -- Disable line numbers
				relativenumber = false, -- Disable relative numbers
				signcolumn = "yes", -- Show the sign column for git status
				float = {
					enable = false, -- Disable floating window
				},
			},

			-- Renderer Settings (Icons, file/folder display)
			renderer = {
				highlight_git = true, -- Highlight files with git status
				highlight_opened_files = "all", -- Highlight all opened files
				icons = {
					show = {
						file = true, -- Show files in the explorer
						folder = true, -- Show folders
						folder_arrow = true, -- Show folder arrows
						git = true, -- Show git status indicators
						modified = true, -- Show modified files
						hidden = true, -- Show hidden files
						diagnostics = true, -- Show diagnostics icons
						bookmarks = true, -- Show bookmarks
					},
					glyphs = {
						default = "", -- Default file icon
						symlink = "", -- Symlink file icon
						bookmark = "󰆤", -- Bookmark file icon
						modified = "●", -- Modified file icon
						hidden = "󰜌", -- Hidden file icon
						folder = {
							arrow_closed = "", -- Closed folder arrow
							arrow_open = "", -- Open folder arrow
							default = "", -- Default folder icon
							open = "", -- Open folder icon
							empty = "", -- Empty folder icon
							empty_open = "", -- Open empty folder icon
							symlink = "", -- Symlink folder icon
							symlink_open = "", -- Open symlink folder icon
						},
						git = {
							unstaged = "✗", -- Unstaged git file icon
							staged = "✓", -- Staged git file icon
							unmerged = "", -- Unmerged git file icon
							renamed = "➜", -- Renamed git file icon
							untracked = "★", -- Untracked git file icon
							deleted = "", -- Deleted git file icon
							ignored = "◌", -- Ignored git file icon
						},
					},
				},
			},

			-- Additional File Management
			hijack_directories = {
				enable = true, -- Enable hijacking of directories
				auto_open = true, -- Automatically open when directory is hijacked
			},

			-- File operations
			actions = {
				open_file = {
					quit_on_open = false, -- Don't quit when file is opened
					resize_window = true, -- Resize window to fit the file
					window_picker = {
						enable = true, -- Enable window picker
						picker = "default", -- Set default picker
						chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
						exclude = {
							filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
							buftype = { "nofile", "terminal", "help" },
						},
					},
				},
			},

			-- Trash settings for deleting files
			trash = {
				cmd = "gio trash", -- Command for trashing files
			},

			-- Git settings
			git = {
				enable = true, -- Enable git integration
				show_on_dirs = true, -- Show git status for directories
				show_on_open_dirs = true, -- Show git status for opened dirs
			},

			-- Diagnostics settings
			diagnostics = {
				enable = true, -- Enable diagnostics
				show_on_dirs = true, -- Show diagnostics for directories
				debounce_delay = 500, -- Delay before diagnostics update
			},

			-- Filters for hiding files
			filters = {
				enable = true, -- Enable filters
				git_ignored = true, -- Hide git ignored files
				dotfiles = false, -- Show dotfiles
			},
		})
	end,
}

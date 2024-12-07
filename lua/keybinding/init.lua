-- require("keybinding.file_explorer")
-- require("keybinding.telescope_explorer")
-- require("keybinding.bufferline_explorer")

local function load_keybindings()
	local keybinding_dir = "keybinding"

	-- Get all Lua files in the keybinding directory
	for _, file in
		ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/" .. keybinding_dir, function(name)
			return name:match("%.lua$") and name ~= "init.lua"
		end))
	do
		-- Remove .lua extension and require the module
		local module_name = file:gsub("%.lua$", "")
		require(keybinding_dir .. "." .. module_name)
	end
end

load_keybindings()

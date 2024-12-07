local function require_lua_plugins()
	local plugins = {}
	local plugin_dir = "plugins.extras"

	for _, file in
		ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/" .. plugin_dir:gsub("%.", "/"), function(name)
			return name:match("%.lua$") and name ~= "init.lua"
		end))
	do
		local module_name = file:gsub("%.lua$", "")
		table.insert(plugins, require(plugin_dir .. "." .. module_name))
	end

	return plugins
end

-- return {
-- 	require("plugins.extras.colorscheme"),
-- 	require("plugins.extras.tmuxnavigator"),
-- }

return require_lua_plugins()

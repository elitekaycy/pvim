local function load_plugin_inits()
	local plugins = {}
	local plugin_base_dir = "plugins"

	for _, dir in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/" .. plugin_base_dir)) do
		local full_path = plugin_base_dir .. "." .. dir .. ".init"

		local ok, init_module = pcall(require, full_path)
		if ok then
			vim.list_extend(plugins, init_module)
		end
	end

	return plugins
end

-- return {
-- 	unpack(require("plugins.default.init")),
-- 	unpack(require("plugins.extras.init")),
-- }

return load_plugin_inits()

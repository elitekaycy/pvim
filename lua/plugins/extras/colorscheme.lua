-- Theme configuration with multiple colorschemes
local theme_file = vim.fn.stdpath("data") .. "/pvim_theme.txt"

-- Available themes configuration
local themes = {
    { name = "kanagawa", colorscheme = "kanagawa", setup = function()
        require("kanagawa").setup({ transparent = true })
    end },
    { name = "kanagawa-wave", colorscheme = "kanagawa-wave", setup = function()
        require("kanagawa").setup({ transparent = true })
    end },
    { name = "kanagawa-dragon", colorscheme = "kanagawa-dragon", setup = function()
        require("kanagawa").setup({ transparent = true })
    end },
    { name = "kanagawa-lotus", colorscheme = "kanagawa-lotus", setup = function()
        require("kanagawa").setup({ transparent = false })
    end },
    { name = "tokyonight", colorscheme = "tokyonight", setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-night", colorscheme = "tokyonight-night", setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-storm", colorscheme = "tokyonight-storm", setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-moon", colorscheme = "tokyonight-moon", setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "catppuccin", colorscheme = "catppuccin", setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-mocha", colorscheme = "catppuccin-mocha", setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-macchiato", colorscheme = "catppuccin-macchiato", setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-frappe", colorscheme = "catppuccin-frappe", setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-latte", colorscheme = "catppuccin-latte", setup = function()
        require("catppuccin").setup({ transparent_background = false })
    end },
    { name = "gruvbox", colorscheme = "gruvbox", setup = function()
        require("gruvbox").setup({ transparent_mode = true })
    end },
    { name = "onedark", colorscheme = "onedark", setup = function()
        require("onedark").setup({ style = "dark", transparent = true })
    end },
    { name = "rose-pine", colorscheme = "rose-pine", setup = function()
        require("rose-pine").setup({ disable_background = true })
    end },
    { name = "rose-pine-moon", colorscheme = "rose-pine-moon", setup = function()
        require("rose-pine").setup({ disable_background = true })
    end },
    { name = "nightfox", colorscheme = "nightfox", setup = function()
        require("nightfox").setup({ options = { transparent = true } })
    end },
    { name = "carbonfox", colorscheme = "carbonfox", setup = function()
        require("nightfox").setup({ options = { transparent = true } })
    end },
    { name = "terafox", colorscheme = "terafox", setup = function()
        require("nightfox").setup({ options = { transparent = true } })
    end },
    { name = "dracula", colorscheme = "dracula", setup = function() end },
    -- Minimal dark themes
    { name = "github-dark", colorscheme = "github_dark", setup = function()
        require("github-theme").setup({ options = { transparent = true } })
    end },
    { name = "github-dimmed", colorscheme = "github_dark_dimmed", setup = function()
        require("github-theme").setup({ options = { transparent = true } })
    end },
    { name = "oxocarbon", colorscheme = "oxocarbon", setup = function() end },
    { name = "nord", colorscheme = "nord", setup = function()
        vim.g.nord_disable_background = true
    end },
    { name = "everforest", colorscheme = "everforest", setup = function()
        vim.g.everforest_transparent_background = 1
        vim.g.everforest_background = "hard"
    end },
    { name = "melange", colorscheme = "melange", setup = function() end },
    { name = "material-deep-ocean", colorscheme = "material", setup = function()
        vim.g.material_style = "deep ocean"
        require("material").setup({ disable = { background = true } })
    end },
    { name = "material-oceanic", colorscheme = "material", setup = function()
        vim.g.material_style = "oceanic"
        require("material").setup({ disable = { background = true } })
    end },
    { name = "material-darker", colorscheme = "material", setup = function()
        vim.g.material_style = "darker"
        require("material").setup({ disable = { background = true } })
    end },
    { name = "moonfly", colorscheme = "moonfly", setup = function()
        vim.g.moonflyTransparent = true
    end },
    { name = "nightfly", colorscheme = "nightfly", setup = function()
        vim.g.nightflyTransparent = true
    end },
    { name = "embark", colorscheme = "embark", setup = function() end },
    { name = "ayu-dark", colorscheme = "ayu-dark", setup = function()
        require("ayu").setup({ mirage = false, overrides = { Normal = { bg = "None" } } })
    end },
    { name = "ayu-mirage", colorscheme = "ayu-mirage", setup = function()
        require("ayu").setup({ mirage = true, overrides = { Normal = { bg = "None" } } })
    end },
    { name = "vscode-dark", colorscheme = "vscode", setup = function()
        require("vscode").setup({ transparent = true, style = "dark" })
    end },
    { name = "zenburn", colorscheme = "zenburn", setup = function() end },
    { name = "monokai-pro", colorscheme = "monokai-pro", setup = function()
        require("monokai-pro").setup({ transparent_background = true })
    end },
    { name = "monokai-classic", colorscheme = "monokai-pro-classic", setup = function()
        require("monokai-pro").setup({ transparent_background = true, filter = "classic" })
    end },
    { name = "sonokai", colorscheme = "sonokai", setup = function()
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_style = "default"
    end },
    { name = "sonokai-shusia", colorscheme = "sonokai", setup = function()
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_style = "shusia"
    end },
    { name = "sonokai-andromeda", colorscheme = "sonokai", setup = function()
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_style = "andromeda"
    end },
    { name = "poimandres", colorscheme = "poimandres", setup = function()
        require("poimandres").setup({ disable_background = true })
    end },
    { name = "cyberdream", colorscheme = "cyberdream", setup = function()
        require("cyberdream").setup({ transparent = true })
    end },
    { name = "fluoromachine", colorscheme = "fluoromachine", setup = function()
        require("fluoromachine").setup({ transparent = true, glow = true })
    end },
}

-- Load saved theme
local function get_saved_theme()
    local file = io.open(theme_file, "r")
    if file then
        local theme = file:read("*l")
        file:close()
        return theme
    end
    return "kanagawa" -- default
end

-- Save theme preference
local function save_theme(name)
    local file = io.open(theme_file, "w")
    if file then
        file:write(name)
        file:close()
    end
end

-- Map theme names to plugin names for lazy loading
local theme_plugins = {
    ["kanagawa"] = "kanagawa.nvim",
    ["tokyonight"] = "tokyonight.nvim",
    ["catppuccin"] = "catppuccin",
    ["gruvbox"] = "gruvbox.nvim",
    ["onedark"] = "onedark.nvim",
    ["rose-pine"] = "rose-pine",
    ["nightfox"] = "nightfox.nvim",
    ["dracula"] = "dracula.nvim",
    ["github"] = "github-nvim-theme",
    ["oxocarbon"] = "oxocarbon.nvim",
    ["nord"] = "nord.nvim",
    ["everforest"] = "everforest",
    ["melange"] = "melange-nvim",
    ["material"] = "material.nvim",
    ["moonfly"] = "moonfly",
    ["nightfly"] = "nightfly",
    ["embark"] = "embark",
    ["ayu"] = "neovim-ayu",
    ["vscode"] = "vscode.nvim",
    ["zenburn"] = "zenburn.nvim",
    ["monokai"] = "monokai-pro.nvim",
    ["sonokai"] = "sonokai",
    ["poimandres"] = "poimandres.nvim",
    ["cyberdream"] = "cyberdream.nvim",
    ["fluoromachine"] = "fluoromachine.nvim",
}

-- Load theme plugin if lazy loaded
local function load_theme_plugin(name)
    for prefix, plugin in pairs(theme_plugins) do
        if name:find("^" .. prefix) then
            local ok = pcall(function()
                require("lazy").load({ plugins = { plugin } })
            end)
            -- Give it a moment to load
            if ok then
                vim.wait(50, function() return false end)
            end
            return
        end
    end
end

-- Apply theme
local function apply_theme(name, save)
    for _, theme in ipairs(themes) do
        if theme.name == name then
            -- Load the plugin first (in case it's lazy loaded)
            load_theme_plugin(name)

            -- Run setup
            local setup_ok = pcall(theme.setup)

            -- Apply colorscheme
            local cs_ok = pcall(vim.cmd, "colorscheme " .. theme.colorscheme)

            if cs_ok then
                -- Apply transparency settings
                vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
                vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
                vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })

                -- Force redraw all windows
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    pcall(vim.api.nvim_win_call, win, function()
                        vim.cmd("redraw!")
                    end)
                end

                if save then
                    save_theme(name)
                    vim.notify("Theme: " .. name, vim.log.levels.INFO)
                end
                return true
            else
                vim.notify("Failed to load theme: " .. name, vim.log.levels.WARN)
            end
        end
    end
    return false
end

-- Theme picker using vim.ui.select
local function pick_theme()
    local theme_names = {}
    for _, theme in ipairs(themes) do
        table.insert(theme_names, theme.name)
    end

    vim.ui.select(theme_names, {
        prompt = "Select Theme:",
        format_item = function(item) return "  " .. item end,
    }, function(choice)
        if choice then
            apply_theme(choice, true)
        end
    end)
end

-- Create user commands
vim.api.nvim_create_user_command("PvimTheme", pick_theme, { desc = "Select pvim theme" })
vim.api.nvim_create_user_command("PvimThemeSet", function(opts)
    if not apply_theme(opts.args, true) then
        vim.notify("Theme not found: " .. opts.args, vim.log.levels.ERROR)
    end
end, { nargs = 1, desc = "Set pvim theme", complete = function()
    local names = {}
    for _, theme in ipairs(themes) do
        table.insert(names, theme.name)
    end
    return names
end })

-- Keybinding
vim.keymap.set("n", "<leader>th", pick_theme, { desc = "Select Theme" })

return {
    -- Main theme (kanagawa)
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
    },
    -- Popular themes
    { "folke/tokyonight.nvim", lazy = true },
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "navarasu/onedark.nvim", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "EdenEast/nightfox.nvim", lazy = true },
    { "Mofiqul/dracula.nvim", lazy = true },
    -- Dark minimal themes
    { "projekt0n/github-nvim-theme", lazy = true },
    { "nyoom-engineering/oxocarbon.nvim", lazy = true },
    { "shaunsingh/nord.nvim", lazy = true },
    { "sainnhe/everforest", lazy = true },
    { "savq/melange-nvim", lazy = true },
    { "marko-cerovac/material.nvim", lazy = true },
    { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true },
    { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = true },
    { "embark-theme/vim", name = "embark", lazy = true },
    { "Shatur/neovim-ayu", lazy = true },
    { "Mofiqul/vscode.nvim", lazy = true },
    { "phha/zenburn.nvim", lazy = true },
    { "loctvl842/monokai-pro.nvim", lazy = true },
    { "sainnhe/sonokai", lazy = true },
    { "olivercederborg/poimandres.nvim", lazy = true },
    { "scottmckendry/cyberdream.nvim", lazy = true },
    { "maxmx03/fluoromachine.nvim", lazy = true },
    -- Load saved theme on startup
    {
        "nvim-lua/plenary.nvim",
        lazy = false,
        priority = 999,
        config = function()
            vim.defer_fn(function()
                local saved = get_saved_theme()
                apply_theme(saved, false)
            end, 10)
        end,
    },
}

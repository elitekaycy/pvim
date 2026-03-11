-- Theme configuration with multiple colorschemes
local theme_file = vim.fn.stdpath("data") .. "/pvim_theme.txt"

-- Available themes configuration
-- transparent = true means force transparent background overrides
-- transparent = false means let the theme control its own background
local themes = {
    -- Dark themes with transparency
    { name = "kanagawa", colorscheme = "kanagawa", transparent = true, setup = function()
        require("kanagawa").setup({ transparent = true })
    end },
    { name = "kanagawa-wave", colorscheme = "kanagawa-wave", transparent = true, setup = function()
        require("kanagawa").setup({ transparent = true })
    end },
    { name = "kanagawa-dragon", colorscheme = "kanagawa-dragon", transparent = true, setup = function()
        require("kanagawa").setup({ transparent = true })
    end },
    { name = "kanagawa-lotus", colorscheme = "kanagawa-lotus", transparent = false, setup = function()
        require("kanagawa").setup({ transparent = false })
    end },
    { name = "tokyonight", colorscheme = "tokyonight", transparent = true, setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-night", colorscheme = "tokyonight-night", transparent = true, setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-storm", colorscheme = "tokyonight-storm", transparent = true, setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-moon", colorscheme = "tokyonight-moon", transparent = true, setup = function()
        require("tokyonight").setup({ transparent = true })
    end },
    { name = "tokyonight-day", colorscheme = "tokyonight-day", transparent = false, setup = function()
        require("tokyonight").setup({ transparent = false })
    end },
    { name = "catppuccin", colorscheme = "catppuccin", transparent = true, setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-mocha", colorscheme = "catppuccin-mocha", transparent = true, setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-macchiato", colorscheme = "catppuccin-macchiato", transparent = true, setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-frappe", colorscheme = "catppuccin-frappe", transparent = true, setup = function()
        require("catppuccin").setup({ transparent_background = true })
    end },
    { name = "catppuccin-latte", colorscheme = "catppuccin-latte", transparent = false, setup = function()
        require("catppuccin").setup({ transparent_background = false })
    end },
    { name = "gruvbox", colorscheme = "gruvbox", transparent = true, setup = function()
        require("gruvbox").setup({ transparent_mode = true })
    end },
    { name = "gruvbox-light", colorscheme = "gruvbox", transparent = false, setup = function()
        vim.o.background = "light"
        require("gruvbox").setup({ transparent_mode = false })
    end },
    { name = "onedark", colorscheme = "onedark", transparent = true, setup = function()
        require("onedark").setup({ style = "dark", transparent = true })
    end },
    { name = "rose-pine", colorscheme = "rose-pine", transparent = true, setup = function()
        require("rose-pine").setup({ disable_background = true })
    end },
    { name = "rose-pine-moon", colorscheme = "rose-pine-moon", transparent = true, setup = function()
        require("rose-pine").setup({ disable_background = true })
    end },
    { name = "rose-pine-dawn", colorscheme = "rose-pine-dawn", transparent = false, setup = function()
        require("rose-pine").setup({ disable_background = false })
    end },
    { name = "nightfox", colorscheme = "nightfox", transparent = true, setup = function()
        require("nightfox").setup({ options = { transparent = true } })
    end },
    { name = "carbonfox", colorscheme = "carbonfox", transparent = true, setup = function()
        require("nightfox").setup({ options = { transparent = true } })
    end },
    { name = "terafox", colorscheme = "terafox", transparent = true, setup = function()
        require("nightfox").setup({ options = { transparent = true } })
    end },
    { name = "dayfox", colorscheme = "dayfox", transparent = false, setup = function()
        require("nightfox").setup({ options = { transparent = false } })
    end },
    { name = "dawnfox", colorscheme = "dawnfox", transparent = false, setup = function()
        require("nightfox").setup({ options = { transparent = false } })
    end },
    { name = "dracula", colorscheme = "dracula", transparent = false, setup = function() end },
    -- GitHub themes
    { name = "github-dark", colorscheme = "github_dark", transparent = true, setup = function()
        require("github-theme").setup({ options = { transparent = true } })
    end },
    { name = "github-dimmed", colorscheme = "github_dark_dimmed", transparent = true, setup = function()
        require("github-theme").setup({ options = { transparent = true } })
    end },
    { name = "github-dark-high-contrast", colorscheme = "github_dark_high_contrast", transparent = true, setup = function()
        require("github-theme").setup({ options = { transparent = true } })
    end },
    { name = "github-light", colorscheme = "github_light", transparent = false, setup = function()
        require("github-theme").setup({ options = { transparent = false } })
    end },
    { name = "github-light-high-contrast", colorscheme = "github_light_high_contrast", transparent = false, setup = function()
        require("github-theme").setup({ options = { transparent = false } })
    end },
    { name = "oxocarbon", colorscheme = "oxocarbon", transparent = false, setup = function() end },
    { name = "nord", colorscheme = "nord", transparent = true, setup = function()
        vim.g.nord_disable_background = true
    end },
    { name = "everforest", colorscheme = "everforest", transparent = true, setup = function()
        vim.g.everforest_transparent_background = 1
        vim.g.everforest_background = "hard"
    end },
    { name = "everforest-light", colorscheme = "everforest", transparent = false, setup = function()
        vim.o.background = "light"
        vim.g.everforest_transparent_background = 0
        vim.g.everforest_background = "soft"
    end },
    { name = "melange", colorscheme = "melange", transparent = false, setup = function()
        vim.o.background = "dark"
    end },
    { name = "melange-light", colorscheme = "melange", transparent = false, setup = function()
        vim.o.background = "light"
    end },
    { name = "material-deep-ocean", colorscheme = "material", transparent = true, setup = function()
        vim.g.material_style = "deep ocean"
        require("material").setup({ disable = { background = true } })
    end },
    { name = "material-oceanic", colorscheme = "material", transparent = true, setup = function()
        vim.g.material_style = "oceanic"
        require("material").setup({ disable = { background = true } })
    end },
    { name = "material-darker", colorscheme = "material", transparent = true, setup = function()
        vim.g.material_style = "darker"
        require("material").setup({ disable = { background = true } })
    end },
    { name = "material-lighter", colorscheme = "material", transparent = false, setup = function()
        vim.g.material_style = "lighter"
        require("material").setup({ disable = { background = false } })
    end },
    { name = "moonfly", colorscheme = "moonfly", transparent = true, setup = function()
        vim.g.moonflyTransparent = true
    end },
    { name = "nightfly", colorscheme = "nightfly", transparent = true, setup = function()
        vim.g.nightflyTransparent = true
    end },
    { name = "embark", colorscheme = "embark", transparent = false, setup = function() end },
    { name = "ayu-dark", colorscheme = "ayu-dark", transparent = true, setup = function()
        require("ayu").setup({ mirage = false, overrides = { Normal = { bg = "None" } } })
    end },
    { name = "ayu-mirage", colorscheme = "ayu-mirage", transparent = true, setup = function()
        require("ayu").setup({ mirage = true, overrides = { Normal = { bg = "None" } } })
    end },
    { name = "ayu-light", colorscheme = "ayu-light", transparent = false, setup = function()
        require("ayu").setup({ mirage = false })
    end },
    { name = "vscode-dark", colorscheme = "vscode", transparent = true, setup = function()
        require("vscode").setup({ transparent = true, style = "dark" })
    end },
    { name = "vscode-light", colorscheme = "vscode", transparent = false, setup = function()
        require("vscode").setup({ transparent = false, style = "light" })
    end },
    { name = "zenburn", colorscheme = "zenburn", transparent = false, setup = function() end },
    { name = "monokai-pro", colorscheme = "monokai-pro", transparent = true, setup = function()
        require("monokai-pro").setup({ transparent_background = true })
    end },
    { name = "monokai-classic", colorscheme = "monokai-pro-classic", transparent = true, setup = function()
        require("monokai-pro").setup({ transparent_background = true, filter = "classic" })
    end },
    { name = "sonokai", colorscheme = "sonokai", transparent = true, setup = function()
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_style = "default"
    end },
    { name = "sonokai-shusia", colorscheme = "sonokai", transparent = true, setup = function()
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_style = "shusia"
    end },
    { name = "sonokai-andromeda", colorscheme = "sonokai", transparent = true, setup = function()
        vim.g.sonokai_transparent_background = 1
        vim.g.sonokai_style = "andromeda"
    end },
    { name = "poimandres", colorscheme = "poimandres", transparent = true, setup = function()
        require("poimandres").setup({ disable_background = true })
    end },
    { name = "cyberdream", colorscheme = "cyberdream", transparent = true, setup = function()
        require("cyberdream").setup({ transparent = true })
    end },
    { name = "fluoromachine", colorscheme = "fluoromachine", transparent = true, setup = function()
        require("fluoromachine").setup({ transparent = true, glow = true })
    end },
    -- Evangelion theme
    { name = "evangelion", colorscheme = "evangelion", transparent = false, setup = function() end },
    -- Noctis themes (dark and light variants)
    { name = "noctis", colorscheme = "noctis", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-azureus", colorscheme = "noctis-azureus", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-bordo", colorscheme = "noctis-bordo", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-minimus", colorscheme = "noctis-minimus", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-uva", colorscheme = "noctis-uva", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-viola", colorscheme = "noctis-viola", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-lux", colorscheme = "noctis-lux", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-lilac", colorscheme = "noctis-lilac", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    { name = "noctis-hibernus", colorscheme = "noctis-hibernus", transparent = false, setup = function()
        require("noctis").setup({})
    end },
    -- Min Theme (minimal)
    { name = "min-theme", colorscheme = "min-theme", transparent = true, setup = function()
        require("min-theme").setup({ theme = "dark", transparent = true })
    end },
    { name = "min-theme-light", colorscheme = "min-theme", transparent = false, setup = function()
        require("min-theme").setup({ theme = "light", transparent = false })
    end },
}

-- Load saved theme (with proper error handling)
local function get_saved_theme()
    local ok, result = pcall(function()
        local file = io.open(theme_file, "r")
        if not file then return nil end
        local theme = file:read("*l")
        file:close()
        return theme
    end)
    if ok and result then
        return result
    end
    return "kanagawa" -- default
end

-- Save theme preference (with proper error handling)
local function save_theme(name)
    local ok, err = pcall(function()
        local file = io.open(theme_file, "w")
        if not file then return end
        file:write(name)
        file:close()
    end)
    if not ok then
        vim.notify("Failed to save theme: " .. tostring(err), vim.log.levels.WARN)
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
    ["evangelion"] = "evangelion.nvim",
    ["noctis"] = "noctis.nvim",
    ["min-theme"] = "min-theme.nvim",
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
                -- Only apply transparency overrides if theme wants it
                if theme.transparent then
                    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
                    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
                    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
                    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
                end

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
    -- New themes
    { "xero/evangelion.nvim", lazy = true },
    { "kartikp10/noctis.nvim", lazy = true },
    { "datsfilipe/min-theme.nvim", lazy = true },
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

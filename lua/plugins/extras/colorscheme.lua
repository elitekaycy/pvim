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
    { name = "dracula", colorscheme = "dracula", setup = function() end },
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

-- Apply theme
local function apply_theme(name, save)
    for _, theme in ipairs(themes) do
        if theme.name == name then
            pcall(theme.setup)
            local ok = pcall(vim.cmd, "colorscheme " .. theme.colorscheme)
            if ok then
                -- Apply transparency
                vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
                vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
                if save then
                    save_theme(name)
                    vim.notify("Theme set to: " .. name, vim.log.levels.INFO)
                end
                return true
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
    -- Additional themes
    { "folke/tokyonight.nvim", lazy = true },
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "navarasu/onedark.nvim", lazy = true },
    { "rose-pine/neovim", name = "rose-pine", lazy = true },
    { "EdenEast/nightfox.nvim", lazy = true },
    { "Mofiqul/dracula.nvim", lazy = true },
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

-- nvim-surround
-- Add, change, delete surrounding brackets, quotes, tags
return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {
        -- Default keymaps:
        -- ys{motion}{char} - add surround
        -- ds{char}         - delete surround
        -- cs{old}{new}     - change surround
        --
        -- Examples:
        -- ysiw"  - surround word with "
        -- ds"    - delete surrounding "
        -- cs"'   - change " to '
        -- yss)   - surround entire line with ()
        -- dst    - delete surrounding tag
    },
}

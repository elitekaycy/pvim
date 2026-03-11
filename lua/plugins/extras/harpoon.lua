-- Harpoon
-- Quick file navigation - mark files and jump instantly
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
        { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
        { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
        { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
        { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
        { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
        { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "Harpoon file 5" },
        { "[h", function() require("harpoon"):list():prev() end, desc = "Harpoon prev file" },
        { "]h", function() require("harpoon"):list():next() end, desc = "Harpoon next file" },
    },
    opts = {
        settings = {
            save_on_toggle = true,
            sync_on_ui_close = true,
        },
    },
    config = function(_, opts)
        require("harpoon"):setup(opts)
    end,
}

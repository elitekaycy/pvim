-- Custom file icons for nvim-web-devicons
return {
    "nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").setup({
            override_by_extension = {
                -- FreeMarker Template
                ["ftl"] = {
                    icon = "",
                    color = "#e44d26",
                    cterm_color = "196",
                    name = "Ftl",
                },
                -- JavaServer Pages
                ["jsp"] = {
                    icon = "",
                    color = "#e44d26",
                    cterm_color = "196",
                    name = "Jsp",
                },
                ["jspx"] = {
                    icon = "",
                    color = "#e44d26",
                    cterm_color = "196",
                    name = "Jspx",
                },
                -- Thymeleaf (if needed)
                ["th"] = {
                    icon = "",
                    color = "#005f0f",
                    cterm_color = "22",
                    name = "Thymeleaf",
                },
            },
        })
    end,
}

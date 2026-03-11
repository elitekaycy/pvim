-- Markdown Preview
-- Live preview in browser as you type
return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    keys = {
        { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
    },
    build = function()
        vim.fn["mkdp#util#install"]()
    end,
    init = function()
        vim.g.mkdp_filetypes = { "markdown" }
        -- Auto-start preview when opening markdown
        vim.g.mkdp_auto_start = 0
        -- Auto-close preview when leaving markdown buffer
        vim.g.mkdp_auto_close = 1
        -- Refresh preview on save or cursor hold
        vim.g.mkdp_refresh_slow = 0
        -- Open preview in new tab
        vim.g.mkdp_open_to_the_world = 0
        -- Use custom IP for preview
        vim.g.mkdp_open_ip = ""
        -- Browser to use
        vim.g.mkdp_browser = ""
        -- Echo preview URL
        vim.g.mkdp_echo_preview_url = 1
        -- Custom preview function
        vim.g.mkdp_browserfunc = ""
        -- Preview options
        vim.g.mkdp_preview_options = {
            mkit = {},
            katex = {},
            uml = {},
            maid = {},
            disable_sync_scroll = 0,
            sync_scroll_type = "middle",
            hide_yaml_meta = 1,
            sequence_diagrams = {},
            flowchart_diagrams = {},
            content_editable = false,
            disable_filename = 0,
            toc = {},
        }
        -- CSS file for preview
        vim.g.mkdp_markdown_css = ""
        vim.g.mkdp_highlight_css = ""
        -- Preview port
        vim.g.mkdp_port = ""
        -- Page title
        vim.g.mkdp_page_title = "「${name}」"
        -- Theme (dark/light)
        vim.g.mkdp_theme = "dark"
    end,
}

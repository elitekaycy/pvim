local lazypath = "~/.local/share/pvim/lazy/lazy.nvim"

if not vim.loop.fs_stat(vim.fn.expand(lazypath)) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        vim.fn.expand(lazypath),
    })
end
vim.opt.rtp:prepend(vim.fn.expand(lazypath))

require("lazy").setup("plugins")

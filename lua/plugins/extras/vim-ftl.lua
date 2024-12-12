return {
    "andreshazard/vim-freemarker",
    config = function()
        local ftl_telescope = require("utils.ftl_telescope")

        vim.cmd("nnoremap <leader>fi :call FTLIf()<CR>")
        vim.cmd("nnoremap <leader>fl :call FTLList()<CR>")
        vim.cmd("nnoremap <leader>fb :call FTLBigList()<CR>")
        vim.cmd("nnoremap <leader>fs :call FTLSwitch()<CR>")
        vim.cmd("nnoremap <leader>fa :call FTLAssign()<CR>")

        vim.cmd [[autocmd FileType ftl setlocal omnifunc=htmlcomplete#CompleteTags]]
        vim.cmd [[autocmd FileType ftl setlocal completeopt=menuone,longest,preview]]
        vim.keymap.set('n', '<leader>ca', ftl_telescope.ftl_code_actions, { noremap = true, silent = true })
    end
}

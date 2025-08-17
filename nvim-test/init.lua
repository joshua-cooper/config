vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.list = true
vim.opt.wrap = false
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.winborder = "solid"
vim.opt.completeopt = "menuone,noinsert,fuzzy"
vim.opt.pumheight = 10
vim.opt.quickfixtextfunc = "v:lua.require'zen.quickfix'.quickfixtextfunc"

vim.keymap.set("n", "<leader>w", "<cmd>silent write<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>confirm quitall<cr>")
vim.keymap.set("n", "<localleader>q", "<cmd>confirm bdelete<cr>")
vim.keymap.set("n", "<leader>e", "<cmd>Explore<cr>")

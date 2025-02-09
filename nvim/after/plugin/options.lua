vim.g.netrw_banner = 0

vim.opt.wrap = false
vim.opt.list = true
vim.opt.listchars = { tab = "· ", trail = "·", extends = "⟩", precedes = "⟨", nbsp = "␣" }
vim.opt.fillchars = { eob = " " }
vim.opt.undofile = true
vim.opt.mousemodel = "extend"
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 5
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.completeopt = "menu"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldmethod = "expr"
vim.opt.foldlevelstart = 99

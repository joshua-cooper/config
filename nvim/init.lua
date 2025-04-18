vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.mapleader = " "
vim.g.maplocalleader = "'"

-- Command line
vim.opt.showcmd = false
vim.opt.showmode = false

-- Completion
vim.opt.completeopt = "menuone,noinsert,fuzzy"
vim.opt.pumheight = 10

-- Floating windows
vim.opt.winborder = "solid"

-- Folds
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1
vim.opt.tabstop = 4

-- Invisible characters
vim.opt.fillchars = { eob = " " }
vim.opt.list = true
vim.opt.listchars = {
	tab = "· ",
	trail = "·",
	extends = "⟩",
	precedes = "⟨",
	nbsp = "␣",
}

-- Scrolling
vim.opt.scrolloff = 5
vim.opt.wrap = false

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Status line
vim.opt.ruler = false
vim.opt.rulerformat = "%=%l:%c"

-- Undo
vim.opt.undofile = true

-- Keymaps
vim.keymap.set("n", "<leader>w", "<cmd>silent update<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>confirm quitall<cr>")

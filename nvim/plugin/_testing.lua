local paq_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "paqs")
local paq_path = vim.fs.joinpath(paq_dir, "start", "paq-nvim")
local paq_repo = "https://github.com/savq/paq-nvim"

if not vim.uv.fs_stat(paq_path) then
	local out = vim.fn.system({ "git", "clone", "--depth=1", paq_repo, paq_path })

	if vim.v.shell_error ~= 0 then
		vim.notify(out, vim.log.levels.ERROR)
		vim.notify("Press any key to exit...")
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(paq_path)

local paq = require("paq")

paq:setup({
	path = paq_dir,
})

paq({
	"savq/paq-nvim",
	"nvim-treesitter/nvim-treesitter",
	"rebelot/kanagawa.nvim",
	"stevearc/oil.nvim",
	"ibhagwan/fzf-lua",
})

paq.install()

require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
	},
})

require("oil").setup({
	default_file_explorer = true,
	skip_confirm_for_simple_edits = true,
	prompt_save_on_select_new_entry = true,
	confirmation = {
		border = "solid",
	},
	view_options = {
		show_hidden = true,
	},
})
vim.keymap.set("n", "-", "<cmd>Oil<cr>")

require("fzf-lua").setup({
	git = {
		files = {
			cmd = "git ls-files --cached --others --exclude-standard",
		},
	},
})
vim.keymap.set("n", "<space>f", "<cmd>FzfLua git_files<cr>")
vim.keymap.set("n", "<space>b", "<cmd>FzfLua buffers<cr>")
vim.keymap.set("n", "<space>g", "<cmd>FzfLua live_grep<cr>")

require("kanagawa").setup({
	theme = "dragon",
	background = {
		dark = "dragon",
		light = "lotus",
	},
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
				},
			},
		},
	},
})

vim.cmd.colorscheme("kanagawa")

vim.g.mapleader = " "

local lazy_dir = vim.fn.stdpath("data") .. "/lazy"
local lazy_path = lazy_dir .. "/lazy.nvim"

if not vim.uv.fs_stat(lazy_path) then
	local output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazy_path,
	})

	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ output },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.runtimepath:prepend(lazy_path)

require("lazy").setup({
	root = lazy_dir,
	install = {
		colorscheme = { "kanagawa-dragon" },
	},
	spec = {
		{
			"rebelot/kanagawa.nvim",
			config = function()
				require("kanagawa").setup({
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

				vim.cmd.colorscheme("kanagawa-dragon")
			end,
		},
		{ import = "custom.plugins" },
	},
	rocks = {
		enabled = false,
	},
	change_detection = {
		enabled = false,
	},
	ui = {
		pills = false,
		icons = {
			cmd = "",
			config = "",
			event = "",
			ft = "",
			init = "",
			keys = "",
			plugin = "",
			runtime = "",
			require = "",
			source = "",
			start = "",
			task = "",
			lazy = "",
		},
	},
})

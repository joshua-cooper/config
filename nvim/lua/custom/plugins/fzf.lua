return {
	{
		"ibhagwan/fzf-lua",
		config = function()
			local fzf = require("fzf-lua")

			fzf.setup({
				defaults = {
					git_icons = false,
					file_icons = false,
				},
				winopts = {
					backdrop = 100,
					preview = {
						winopts = {
							number = false,
							cursorline = false,
						},
					},
				},
			})

			fzf.register_ui_select()

			vim.keymap.set("n", "<leader>f", "", {
				desc = "Files",
				callback = fzf.files,
			})

			vim.keymap.set("n", "<leader>b", "", {
				desc = "Buffers",
				callback = fzf.buffers,
			})

			vim.keymap.set("n", "<leader>d", "", {
				desc = "Diagnostics",
				callback = fzf.diagnostics_workspace,
			})

			vim.keymap.set("n", "<leader>/", "", {
				desc = "Search",
				callback = fzf.live_grep,
			})

			vim.keymap.set("n", "<leader>gb", "", {
				desc = "Git branches",
				callback = fzf.git_branches,
			})

			vim.keymap.set("n", "<leader>gt", "", {
				desc = "Git tags",
				callback = fzf.git_tags,
			})

			vim.keymap.set("n", "<leader>gc", "", {
				desc = "Git commits",
				callback = fzf.git_commits,
			})
		end,
	},
}

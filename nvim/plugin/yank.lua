vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function(_)
		vim.hl.on_yank({
			higroup = "Visual",
			timeout = 200,
			on_visual = false,
		})
	end,
})

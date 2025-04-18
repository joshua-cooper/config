local function fzf()
	local buffer = vim.api.nvim_create_buf(false, true)
	local window = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = 70,
		height = 20,
		row = 1,
		col = 1,
		zindex = 150,
	})

	vim.api.nvim_create_autocmd({ "TermLeave", "BufLeave", "WinLeave" }, {
		buffer = buffer,
		callback = function(args)
			vim.api.nvim_buf_delete(buffer, {
				force = true,
			})
		end,
	})

	vim.fn.jobstart("rg '' | fzf --ansi --multi --bind 'change:reload(rg --color always {q})' | tee /tmp/fzfing", {
		term = true,
	})
	vim.cmd.startinsert()
end

vim.api.nvim_create_user_command("UnstableFzf", function()
	fzf()
end, {
	desc = "Unstable fzf",
})

vim.api.nvim_create_user_command("UnstableFzfTmux", function()
	local cmd = "rg --files | fzf --tmux bottom,100%,60%,border-native --layout reverse"
	local result = vim.fn.system(cmd)
	if vim.v.shell_error == 0 and result ~= "" then
		local file = vim.trim(result)
		vim.cmd("edit " .. vim.fn.fnameescape(file))
	end
end, {
	desc = "Unstable fzf",
})

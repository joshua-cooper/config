local function my_grep()
	local regex = vim.call("input", "grep: ")

	if regex == "" then
		return
	end

	local escaped_regex = vim.call("escape", regex, "\"")
	local quoted_regex = ("\"%s\""):format(escaped_regex)

	vim.cmd.vimgrep({
		args = {
			quoted_regex,
			"**/*",
		},
		mods = {
			silent = true,
		},
		-- TODO: With `grep` this prevents opening the first result,
		-- but not with vimgrep. We want to avoid opening the first
		-- result if possible.
		bang = true,
	})

	vim.cmd.copen()
end

local function fuzzy()
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "laststatus",
		row = 1,
		col = 1,
		height = math.min(10, math.floor(vim.o.lines * 0.4)),
		width = vim.o.columns,
	})

	vim.api.nvim_set_option_value("fillchars", "eob: ", {
		win = win
	})

	local function render()
		local input = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ""

		local result = vim.system({ "rg", input }, { text = true }):wait()
		local lines = vim.split(result.stdout, "\n")

		local output = { input }
		vim.list_extend(output, lines)

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
	end

	render()
	vim.cmd("startinsert")

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = buf,
		callback = function(_)
			render()
		end,
	})

	vim.api.nvim_create_autocmd("InsertLeave", {
		buffer = buf,
		callback = function(_)
			vim.api.nvim_win_close(win, true)
		end,
	})

	local saved_col = 0

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = buf,
		callback = function(_)
			local cursor = vim.api.nvim_win_get_cursor(win)

			if cursor[1] ~= 1 then
				vim.api.nvim_win_set_cursor(win, {
					1,
					saved_col,
				})
			else
				saved_col = cursor[2]
			end
		end
	})
end

vim.keymap.set("n", "<leader>r", function()
	fuzzy()
end)

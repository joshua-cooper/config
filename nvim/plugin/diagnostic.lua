local function priority_severity(buffer)
	local error_count = vim.diagnostic.count(buffer)[vim.diagnostic.severity.ERROR] or 0

	if error_count > 0 then
		return vim.diagnostic.severity.ERROR
	else
		return vim.diagnostic.severity.WARN
	end
end

vim.diagnostic.config({
	signs = false,
	underline = false,
	update_in_insert = true,
	virtual_text = false,
	virtual_lines = false,
	severity_sort = true,
	jump = {
		float = true,
		severity = {
			min = vim.diagnostic.severity.WARN,
		},
	},
	float = {
		severity_sort = true,
	},
})

vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({
		count = vim.v.count1,
		severity = priority_severity(0),
	})
end, {
	desc = "Jump to the next diagnostic in the current buffer",
})

vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({
		count = -vim.v.count1,
		severity = priority_severity(0),
	})
end, {
	desc = "Jump to the previous diagnostic in the current buffer",
})

vim.keymap.set("n", "]D", function()
	vim.diagnostic.jump({
		count = math.huge,
		wrap = false,
		severity = priority_severity(0),
	})
end, {
	desc = "Jump to the last diagnostic in the current buffer",
})

vim.keymap.set("n", "[D", function()
	vim.diagnostic.jump({
		count = -math.huge,
		wrap = false,
		severity = priority_severity(0),
	})
end, {
	desc = "Jump to the first diagnostic in the current buffer",
})

vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.setqflist({
		severity = priority_severity(),
	})
end, {
	desc = "vim.diagnostic.setqflist()",
})

vim.keymap.set("n", "<localleader>d", function()
	vim.diagnostic.setloclist({
		severity = priority_severity(0),
	})
end, {
	desc = "vim.diagnostic.setloclist()",
})

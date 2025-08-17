---@param bufnr? integer
---@return integer?
local function priority_severity(bufnr)
	local counts = vim.diagnostic.count(bufnr)

	for severity = vim.diagnostic.severity.ERROR, vim.diagnostic.severity.HINT do
		if counts[severity] and counts[severity] > 0 then
			return severity
		end
	end
end

local function jump_next()
	vim.diagnostic.jump({
		count = vim.v.count1,
		severity = priority_severity(0),
	})
end

local function jump_previous()
	vim.diagnostic.jump({
		count = -vim.v.count1,
		severity = priority_severity(0),
	})
end

local function jump_first()
	vim.diagnostic.jump({
		count = -math.huge,
		wrap = false,
		severity = priority_severity(0),
	})
end

local function jump_last()
	vim.diagnostic.jump({
		count = math.huge,
		wrap = false,
		severity = priority_severity(0),
	})
end

local function setqflist()
	vim.diagnostic.setqflist({
		severity = priority_severity(),
	})
end

local function setloclist()
	vim.diagnostic.setloclist({
		severity = priority_severity(0),
	})
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
	},
	float = {
		header = "",
	},
})

vim.keymap.set("n", "]d", jump_next, {
	desc = "Jump to the next priority diagnostic in the current buffer",
})

vim.keymap.set("n", "[d", jump_previous, {
	desc = "Jump to the previous priority diagnostic in the current buffer",
})

vim.keymap.set("n", "[D", jump_first, {
	desc = "Jump to the first priority diagnostic in the current buffer",
})

vim.keymap.set("n", "]D", jump_last, {
	desc = "Jump to the last priority diagnostic in the current buffer",
})

vim.keymap.set("n", "<leader>d", setqflist, {
	desc = "Add all priority diagnostics to the quickfix list",
})

vim.keymap.set("n", "<localleader>d", setloclist, {
	desc = "Add buffer priority diagnostics to the location list",
})

local function priority_severity_filter()
	local counts = vim.diagnostic.count()

	if counts[vim.diagnostic.severity.ERROR] ~= nil then
		return {
			min = vim.diagnostic.severity.ERROR,
		}
	end

	if counts[vim.diagnostic.severity.WARN] ~= nil then
		return {
			min = vim.diagnostic.severity.WARN,
		}
	end

	return nil
end

vim.diagnostic.config({
	signs = false,
	underline = false,
	update_in_insert = false,
	virtual_text = {
		severity = {
			min = vim.diagnostic.severity.WARN,
		},
	},
	severity_sort = true,
})

vim.keymap.set("n", "[d", "", {
	desc = "Go to prev diagnostic",
	callback = function()
		vim.diagnostic.goto_prev({
			severity = priority_severity_filter(),
		})
	end,
})

vim.keymap.set("n", "]d", "", {
	desc = "Go to next diagnostic",
	callback = function()
		vim.diagnostic.goto_next({
			severity = priority_severity_filter(),
		})
	end,
})

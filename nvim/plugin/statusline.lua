local ICON = "•"
local OK_DIAGNOSTIC_ICON = "%#DiagnosticSignOk#" .. ICON .. "%*"
local WARN_DIAGNOSTIC_ICON = "%#DiagnosticSignWarn#" .. ICON .. "%*"
local ERROR_DIAGNOSTIC_ICON = "%#DiagnosticSignError#" .. ICON .. "%*"

local BUSY_LSP_CLIENTS = {}
local BUSY_RETENTION_MS = 300

local function diagnostics()
	local buffer = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
	local counts = vim.diagnostic.count(buffer)
	local error_count = counts[vim.diagnostic.severity.ERROR] or 0
	local warn_count = counts[vim.diagnostic.severity.WARN] or 0

	if error_count > 0 then
		return ERROR_DIAGNOSTIC_ICON
	end

	if warn_count > 0 then
		return WARN_DIAGNOSTIC_ICON
	end

	return OK_DIAGNOSTIC_ICON
end

local function activity()
	local now = vim.uv.now()
	local buffer = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)

	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buffer })) do
		local client_state = BUSY_LSP_CLIENTS[client.id]

		if client_state ~= nil then
			local is_busy = client_state.count > 0
			local should_retain = now - client_state.last < BUSY_RETENTION_MS

			if is_busy or should_retain then
				return ICON
			end
		end
	end

	return " "
end

function _G.statusline()
	return table.concat({
		" ",
		diagnostics(),
		" %f %m%= ",
		activity(),
		" ",
	})
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		vim.cmd.redrawstatus({ bang = true })
	end,
})

vim.api.nvim_create_autocmd("LspProgress", {
	callback = function(event)
		local client_id = event.data.client_id
		local kind = event.data.params.value.kind
		local now = vim.uv.now()
		local entry = BUSY_LSP_CLIENTS[client_id] or { count = 0, last = now }

		if kind == "begin" then
			entry.count = entry.count + 1
		elseif kind == "end" then
			entry.count = math.max(entry.count - 1, 0)
		end

		entry.last = now
		BUSY_LSP_CLIENTS[client_id] = entry
		vim.cmd.redrawstatus({ bang = true })

		vim.defer_fn(function()
			local client_state = BUSY_LSP_CLIENTS[client_id]

			if client_state and client_state.count == 0 then
				vim.cmd.redrawstatus({ bang = true })
			end
		end, BUSY_RETENTION_MS)
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	callback = function(event)
		BUSY_LSP_CLIENTS[event.data.client_id] = nil
	end,
})

vim.opt.statusline = "%!v:lua.statusline()"

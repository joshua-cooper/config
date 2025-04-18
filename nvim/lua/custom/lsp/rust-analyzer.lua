local M = {}

local function notify_server_error(error)
	vim.notify(("[rust-analyzer] (%d) %s"):format(error.code, error.message), vim.log.levels.ERROR)
end

function M.reload_workspace()
	local method = "rust-analyzer/reloadWorkspace"
	local clients = vim.lsp.get_clients({
		bufnr = 0,
		name = "rust-analyzer",
		method = method,
	})

	for _, client in ipairs(clients) do
		client:request(method, nil, function(error)
			if error ~= nil then
				notify_server_error(error)
				return
			end

			vim.notify("Workspace reloaded")
		end)
	end
end

function M.expand_macro()
	local method = "rust-analyzer/expandMacro"
	local clients = vim.lsp.get_clients({
		bufnr = 0,
		name = "rust-analyzer",
		method = method,
	})
	local client = clients[#clients]

	if client == nil then
		vim.notify("No active rust-analyzer LSP clients")
		return
	end

	client:request(
		method,
		vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-8"),
		function(error, result, ctx)
			local bufnr = assert(ctx.bufnr)

			if vim.api.nvim_get_current_buf() ~= bufnr then
				-- Ignore result since buffer changed.
				return
			end

			if error ~= nil then
				notify_server_error(error)
				return
			end

			if result == nil then
				vim.notify("No macro under the cursor")
				return
			end

			local lines = vim.split(result.expansion, "\n", {
				plain = true,
				trimempty = true,
			})

			vim.lsp.util.open_floating_preview(lines, "rust", {
				focus_id = method,
				wrap = vim.o.wrap,
			})
		end
	)
end

return M

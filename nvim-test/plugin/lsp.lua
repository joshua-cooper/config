---@type table<integer, table<integer, integer[]>>
local autocmd_ids = {}

local function toggle_inlay_hints()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end

local group = vim.api.nvim_create_augroup("zen.lsp", {
	clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(lsp_attach_args)
		local buf = lsp_attach_args.buf
		local client = assert(vim.lsp.get_client_by_id(lsp_attach_args.data.client_id))

		---@param autocmd_id integer
		local function push_autocmd_id(autocmd_id)
			autocmd_ids[buf] = autocmd_ids[buf] or {}
			autocmd_ids[buf][client.id] = autocmd_ids[buf][client.id] or {}
			table.insert(autocmd_ids[buf][client.id], autocmd_id)
		end

		if client:supports_method("textDocument/completion", buf) then
			vim.lsp.completion.enable(true, client.id, buf)
		end

		if not client:supports_method("textDocument/willSaveWaitUntil", buf)
		    and client:supports_method("textDocument/formatting", buf) then
			push_autocmd_id(vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = buf,
				desc = "Format the buffer on save",
				callback = function(_)
					vim.lsp.buf.format({
						id = client.id,
						bufnr = buf,
					})
				end,
			}))
		end

		if client:supports_method("textDocument/codeLens", buf) then
			local events = {
				"LspProgress",
				"BufEnter",
				"TextChanged",
				"InsertLeave",
			}

			push_autocmd_id(vim.api.nvim_create_autocmd(events, {
				buffer = buf,
				desc = "Refresh codelens",
				callback = function(args)
					if args.event ~= "LspProgress" or args.file == "end" then
						vim.lsp.codelens.refresh({
							bufnr = buf
						})
					end
				end,
			}))
		end
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	group = group,
	callback = function(lsp_detach_args)
		local buf = lsp_detach_args.buf
		local client = assert(vim.lsp.get_client_by_id(lsp_detach_args.data.client_id))

		if autocmd_ids[buf] and autocmd_ids[buf][client.id] then
			for _, autocmd_id in ipairs(autocmd_ids[buf][client.id]) do
				vim.api.nvim_del_autocmd(autocmd_id)
			end

			autocmd_ids[buf][client.id] = nil
		end

		if autocmd_ids[buf] and next(autocmd_ids[buf]) == nil then
			autocmd_ids[buf] = nil
		end
	end,
})

vim.keymap.set("n", "grh", toggle_inlay_hints, {
	desc = "Toggle inlay hints",
})

for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
	vim.lsp.enable(vim.fn.fnamemodify(path, ":t:r"))
end

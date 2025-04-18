vim.lsp.enable({
	"luals",
	"rust-analyzer",
	"svelte",
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		if client == nil then
			return
		end

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, {
				autotrigger = false,
			})
		end

		if client:supports_method("textDocument/foldingRange") then
			vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		if client:supports_method("textDocument/formatting") then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format()
				end,
			})
		end

		if client:supports_method("textDocument/codeLens") then
			vim.api.nvim_create_autocmd("BufWritePost", {
				buffer = args.buf,
				callback = vim.lsp.codelens.refresh,
			})

			vim.lsp.codelens.refresh()
		end
	end,
})

-- Mapped unconditionally, similar to default maps for LSP functions.
vim.keymap.set("n", "grt", function()
	vim.lsp.buf.type_definition()
end, {
	desc = "vim.lsp.buf.type_definition()",
})

vim.keymap.set("n", "grl", function()
	vim.lsp.codelens.run()
	vim.lsp.codelens.refresh()
end, {
	desc = "Run codelens and refresh",
})

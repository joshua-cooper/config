return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsp = require("lspconfig")

			lsp.rust_analyzer.setup({
				settings = {
					["rust-analyzer"] = {},
				},
			})
		end,
	},
}

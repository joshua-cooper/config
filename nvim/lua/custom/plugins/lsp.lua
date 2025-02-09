return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lsp = require("lspconfig")

			lsp.rust_analyzer.setup({
				settings = {
					-- TODO: settings
					["rust-analyzer"] = {},
				},
			})

			-- TODO: keymaps
			-- TODO: folds aren't working?
		end,
	},
}

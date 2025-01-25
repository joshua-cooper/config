return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				default_format_opts = {
					lsp_format = "fallback",
				},
				format_on_save = {
					timeout_ms = 1000,
				},
				formatters_by_ft = {
					lua = { "stylua" },
				},
			})

			vim.opt.formatexpr = "v:lua.require('conform').formatexpr()"
		end,
	},
}

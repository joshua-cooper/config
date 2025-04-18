local function is_external_library(path)
	local joinpath = vim.fs.joinpath

	local user_home = vim.uv.os_homedir()
	local cargo_home = vim.env.CARGO_HOME or joinpath(user_home, ".cargo")
	local rustup_home = vim.env.RUSTUP_HOME or joinpath(user_home, ".rustup")

	local cargo_registry = joinpath(cargo_home, "registry", "src")
	local git_registry = joinpath(cargo_home, "git", "checkouts")
	local toolchains = joinpath(rustup_home, "toolchains")
	local nix_store = "/nix/store"

	local library_dirs = {
		cargo_registry,
		git_registry,
		toolchains,
		nix_store,
	}

	for _, dir in ipairs(library_dirs) do
		if vim.fs.relpath(dir, path) ~= nil then
			return true
		end
	end

	return false
end

return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
			cargo = {
				features = "all",
			},
			files = {
				excludeDirs = {
					".direnv",
				},
			},
			lru = {
				capacity = 65535,
			},
			lens = {
				enable = true,
				run = {
					enable = true,
				},
				debug = {
					enable = true,
				},
			},
		},
	},
	capabilities = {
		experimental = {
			serverStatusNotification = true,
			commands = {
				commands = {
					"rust-analyzer.runSingle",
					"rust-analyzer.debugSingle",
				},
			},
		},
	},
	root_dir = function(buffer, callback)
		local crate_dir = vim.fs.root(buffer, "Cargo.toml")

		if crate_dir == nil then
			local rust_project_dir = vim.fs.root(buffer, "rust-project.json")

			if rust_project_dir ~= nil then
				callback(rust_project_dir)
			end

			return
		end

		local command = {
			"cargo",
			"metadata",
			"--no-deps",
			"--format-version",
			"1",
		}

		if vim.fn.executable(command[1]) == 0 then
			callback(crate_dir)
			return
		end

		local opts = {
			text = true,
			cwd = crate_dir,
		}

		vim.system(command, opts, function(result)
			if result.code ~= 0 then
				vim.schedule(function()
					vim.notify(
						("Got an error from `cargo metadata`:\n\n%s"):format(result.stderr),
						vim.log.levels.ERROR
					)
				end)
				callback(crate_dir)
				return
			end

			local output = vim.json.decode(result.stdout)

			if output.workspace_root then
				callback(vim.fs.normalize(output.workspace_root))
			else
				vim.schedule(function()
					vim.notify("No workspace_root returned from `cargo metadata`", vim.log.levels.WARN)
				end)
				callback(crate_dir)
			end
		end)
	end,
	reuse_client = function(client, config)
		if client.name ~= config.name then
			return false
		end

		if client.root_dir == config.root_dir then
			return true
		end

		if is_external_library(config.root_dir) then
			return true
		end

		return false
	end,
	before_init = function(init_params, config)
		if config.settings and config.settings["rust-analyzer"] then
			init_params.initializationOptions = config.settings["rust-analyzer"]
		end
	end,
	on_attach = function(_, buffer)
		vim.api.nvim_buf_create_user_command(buffer, "LspReloadWorkspace", function()
			require("custom.lsp.rust-analyzer").reload_workspace()
		end, {
			desc = "Reload workspace (rust-analyzer)",
		})

		vim.api.nvim_buf_create_user_command(buffer, "LspExpandMacro", function()
			require("custom.lsp.rust-analyzer").expand_macro()
		end, {
			desc = "Expand macro under the cursor (rust-analyzer)",
		})

		vim.keymap.set("n", "grm", function()
			require("custom.lsp.rust-analyzer").expand_macro()
		end, {
			desc = "Expand macro",
			buffer = buffer,
		})
	end,
	commands = {
		["rust-analyzer.runSingle"] = function(command)
			local args = command.arguments[1].args
			local cargo_command = { "cargo" }

			for _, arg in ipairs(args.cargoArgs or {}) do
				table.insert(cargo_command, arg)
			end

			for _, arg in ipairs(args.cargoExtraArgs or {}) do
				table.insert(cargo_command, arg)
			end

			table.insert(cargo_command, "--")

			for _, arg in ipairs(args.executableArgs or {}) do
				table.insert(cargo_command, arg)
			end

			require("custom.terminal").open({
				name = "test",
				command = cargo_command,
				cwd = args.workspaceRoot,
				replace = true,
				split = "bottom",
			})
		end,
	},
}

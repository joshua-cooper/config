local function get_items(info)
	local opts = {
		id = info.id,
		items = 0,
	}

	if info.quickfix == 1 then
		return vim.fn.getqflist(opts).items
	else
		return vim.fn.getloclist(info.winid, opts).items
	end
end

local function format_nix_name(name)
	return name:gsub("^/nix/store/[0-9a-z]+%-([^/]+)/", "[nix:%1] ")
end

local function format_cargo_name(name)
	local cargo_home = vim.env.CARGO_HOME or vim.fs.joinpath(vim.uv.os_homedir(), ".cargo")
	-- TODO
	local escaped_cargo_home = vim.pesc(cargo_home:gsub("\\", "/"))

	name = name:gsub("/.cargo/registry/src/[^/]+/([^/]+)/", "[cargo:%1] ")
	name = name:gsub("/.cargo/git/checkouts/([^/]+)%-[0-9a-f]+/[0-9a-f]+/", "[cargo-git:%1] ")
	return name
end

local function format_name(entry)
	if entry.module and entry.module ~= "" then
		return entry.module
	end

	local name = ""

	if entry.bufnr and entry.bufnr > 0 then
		name = vim.fn.bufname(entry.bufnr)
	end

	if name == "" and entry.filename then
		name = entry.filename
	end

	local cwd = vim.fn.getcwd()

	name = name:gsub(("^%s/"):format(vim.pesc(cwd)), "")
	name = format_nix_name(name)
	name = format_cargo_name(name)

	return name
end

local function format_metadata(entry)
	---@type string[]
	local parts = {}

	if entry.lnum > 0 then
		local col = entry.col > 0 and entry.col or 1
		table.insert(parts, ("%d:%d"):format(entry.lnum, col))
	elseif entry.pattern and entry.pattern ~= "" then
		table.insert(parts, entry.pattern)
	end

	if entry.type ~= "" then
		local type_strings = {
			E = "error",
			W = "warning",
			I = "info",
			N = "note",
		}

		table.insert(parts, type_strings[entry.type] or entry.type)
	end

	if entry.nr > 0 then
		table.insert(parts, tostring(entry.nr))
	end

	return table.concat(parts, " ")
end

local function format_message(message)
	return message:gsub("[%c]+", " "):gsub("^%s+", "")
end

function _G.zen_quickfixtextfunc(info)
	local items = get_items(info)

	---@type string[]
	local out = {}

	for i = info.start_idx, info.end_idx do
		local entry = items[i]

		local message = format_message(entry.text)

		if entry.valid == 0 then
			table.insert(out, message)
		else
			local name = format_name(entry)
			local metadata = format_metadata(entry)

			if name == "" then
				table.insert(out, ("|%s| %s"):format(metadata, message))
			else
				table.insert(out, ("%s |%s| %s"):format(name, metadata, message))
			end
		end
	end

	return out
end

local function enable_testing()
	local qf_items = {
		-- Valid entries with different metadata
		{
			filename = vim.fn.getcwd() .. "/src/local.rs",
			lnum = 77,
			col = 12,
			type = "W",
			text = "file in current working directory",
		},
		{
			filename = "src/main.rs",
			lnum = 10,
			col = 5,
			end_col = 15,
			type = "E",
			text = "cannot find value `foo` in this scope",
		},
		{
			filename = "src/lib.rs",
			lnum = 25,
			col = 8,
			type = "W",
			text = "unused variable: `bar`",
		},
		{
			filename = "src/utils.rs",
			lnum = 100,
			col = 1,
			end_col = 10,
			type = "I",
			text = "this is an info message with\nmultiple\nlines",
		},
		{
			filename = "src/test.rs",
			lnum = 5,
			col = 0, -- No column
			type = "N",
			text = "note: this is a note",
		},

		-- Entry with only line number
		{
			filename = "Makefile",
			lnum = 15,
			text = "missing separator",
		},

		-- Entry with error number
		{
			filename = "src/data.rs",
			lnum = 42,
			col = 10,
			nr = 1234,
			text = "error with number E1234",
		},

		-- Invalid entry (header/separator)
		{
			text = "==== Build Errors ====",
			valid = 0,
		},

		-- Long filename paths
		{
			filename =
			"/home/user/projects/my-rust-project/target/debug/deps/some_crate-abc123/src/deeply/nested/module/file.rs",
			lnum = 99,
			col = 5,
			type = "E",
			text = "long path error",
		},

		-- Nix store path
		{
			filename = "/nix/store/abc123def-rust-1.75.0/lib/rustlib/src/rust/library/core/src/option.rs",
			lnum = 123,
			col = 10,
			type = "W",
			text = "nix store warning",
		},

		-- Cargo registry path
		{
			filename = vim.fn.expand(
				"~/.cargo/registry/src/index.crates.io-6f17d22bba15001f/tokio-1.35.0/src/net/tcp.rs"),
			lnum = 200,
			col = 15,
			end_col = 25,
			type = "E",
			text = "tokio error message",
		},

		-- Node modules path
		{
			filename = "node_modules/express/lib/router/index.js",
			lnum = 50,
			col = 3,
			type = "W",
			text = "express warning",
		},

		-- Entry with pattern instead of line
		{
			filename = "src/search.rs",
			pattern = "fn process_data",
			text = "function needs documentation",
		},

		-- Entry with module name
		{
			filename = "src/module.rs",
			lnum = 30,
			module = "my_module::submodule",
			text = "module-specific error",
		},

		-- Invalid entry with no file
		{
			text = "General error without file location",
			valid = 1, -- Valid but no location
		},

		-- Invalid entry with no file
		{
			text = "General error without file location",
			valid = 1, -- Valid but no location
			lnum = 30,
		},

		-- Entry with very long text
		{
			filename = "src/long.rs",
			lnum = 1,
			col = 1,
			text = "This is a very long error message that might wrap in the quickfix window. " ..
			    string.rep("Lorem ipsum dolor sit amet. ", 10),
		},

		-- Invalid entry with no file
		{
			text = "General error without file location",
			valid = 1, -- Valid but no location
			lnum = 30,
		},

		-- Entry with error number and no type
		{
			filename = "src/data.rs",
			lnum = 42,
			col = 10,
			nr = 1234,
			text = "no type with number E1234",
		},


		-- Entry with error number and error type
		{
			filename = "src/data.rs",
			lnum = 42,
			col = 10,
			type = "E",
			nr = 1234,
			text = "error with number E1234",
		},


		-- Entry with error number and warning
		{
			filename = "src/data.rs",
			lnum = 42,
			col = 10,
			type = "W",
			nr = 1234,
			text = "warning with number E1234",
		},


		-- Entry with error number and unknown
		{
			filename = "src/data.rs",
			lnum = 42,
			col = 10,
			type = "L",
			nr = 1234,
			text = "unknown with number E1234",
		},

		-- invalid with details
		{
			filename = "src/data.rs",
			lnum = 42,
			col = 10,
			valid = 1,
			type = "E",
			nr = 1234,
			text = "invalid with metadata",
		},

		-- Entry with no text
		{
			filename = "src/none.rs",
			lnum = 1,
			col = 1,
		},

		-- Entry with trailing whitespace text
		{
			filename = "src/trailing.rs",
			lnum = 1,
			col = 1,
			text = "trailing whitespace   ",
		},

	}

	vim.opt.spell = false
	-- vim.cmd.colorscheme("retrobox")
	vim.fn.setqflist(qf_items, 'r')
	vim.cmd('copen')
end

-- enable_testing()

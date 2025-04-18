local function format_metadata(entry)
	if entry.lnum == 0 then
		if entry.pattern then
			return entry.pattern
		else
			return ""
		end
	else
		local pos

		if entry.col == 0 then
			pos = ("%d"):format(entry.lnum)
		else
			pos = ("%d:%d"):format(entry.lnum, entry.col)
		end

		if entry.type ~= "" then
			return ("%s %s"):format(pos, entry.type)
		else
			return pos
		end
	end
end

local function format_nix_name(name)
	return name:gsub("^/nix/store/[0-9a-z]+%-([^/]+)/", function(pkg)
		pkg = pkg:gsub("%-?%d[%w%.-]*$", "")
		return ("[nix:%s] "):format(pkg)
	end)
end

local function format_rust_name(name)
	local cargo_home = vim.env.CARGO_HOME or vim.fs.joinpath(vim.uv.os_homedir(), ".cargo")
	local escaped_cargo_home = vim.pesc(cargo_home:gsub("\\", "/"))

	local registry_pattern = ("^%s/registry/src/([^/]+)-[0-9a-f]+/([^/]+)/"):format(escaped_cargo_home)
	local git_pattern = ("^%s/git/checkouts/([^/]+)-[0-9a-f]+/[0-9a-f]+/"):format(escaped_cargo_home)

	name = name:gsub(registry_pattern, function(registry, crate)
		registry = registry:gsub("^index%.", ""):gsub("-[0-9a-f]+$", "")
		crate = crate:gsub("%-%d[%w%.-]*$", "")
		return ("[%s:%s] "):format(registry, crate)
	end)

	name = name:gsub(git_pattern, "[git:%1] ")

	return name
end

function _G.quickfixtextfunc(info)
	local cwd = vim.fn.getcwd()
	local items = (info.quickfix == 1) and vim.fn.getqflist({ id = info.id, items = 0 }).items
		or vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items

	local out = {}

	for i = info.start_idx, info.end_idx do
		local entry = items[i]
		local normalized_text = entry.text:gsub("[%c]+", " "):gsub("^%s+", "")

		if entry.valid == 0 and entry.bufnr == 0 then
			table.insert(out, normalized_text)
		else
			local name = vim.fn.bufname(entry.bufnr):gsub("\\", "/")

			name = name:gsub(("^%s/"):format(vim.pesc(cwd)), "")
			name = format_nix_name(name)
			name = format_rust_name(name)

			if name == "" then
				name = "[No Name]"
			end

			table.insert(out, ("%s |%s| %s"):format(name, format_metadata(entry), normalized_text))
		end
	end

	return out
end

vim.opt.quickfixtextfunc = "v:lua.quickfixtextfunc"

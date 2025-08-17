local M = {}

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

---@return string
local function format_label(item)
	if item.module and item.module ~= "" then
		return item.module
	end

	local label = ""

	if item.bufnr and item.bufnr > 0 then
		label = vim.api.nvim_buf_get_name(item.bufnr)
	end

	if label == "" and item.filename then
		label = item.filename
	end

	if label == "" then
		return ""
	end

	local cwd = vim.fn.getcwd()
	local cargo_home = vim.env.CARGO_HOME or vim.fs.joinpath(vim.uv.os_homedir(), ".cargo")
	local escaped_cargo_home = vim.pesc(cargo_home)

	local patterns = {}

	if cwd ~= "" and cwd ~= "/" then
		table.insert(patterns, {
			("^%s/"):format(vim.pesc(cwd)),
			""
		})
	end

	table.insert(patterns, {
		"^/nix/store/[0-9a-z]+%-([^/]+)/",
		"[nix:%1] "
	})

	table.insert(patterns, {
		("^%s/registry/src/([^/]+)-[0-9a-f]+/([^/]+)/"):format(escaped_cargo_home),
		function(registry, crate)
			registry = registry:gsub("^index%.", "")
			return ("[%s:%s] "):format(registry, crate)
		end
	})

	table.insert(patterns, {
		("^%s/git/checkouts/([^/]+)-[0-9a-f]+/[0-9a-f]+/"):format(escaped_cargo_home),
		"[git:%1] "
	})

	for _, pattern in ipairs(patterns) do
		local s, n = label:gsub(pattern[1], pattern[2])

		if n > 0 then
			return s
		end
	end

	return label
end

---@return string
local function format_metadata(item)
	---@type string[]
	local parts = {}

	if item.lnum > 0 then
		local col = item.col > 0 and item.col or 1
		table.insert(parts, ("%d:%d"):format(item.lnum, col))
	elseif item.pattern and item.pattern ~= "" then
		table.insert(parts, item.pattern)
	end

	if item.type ~= "" then
		local type = item.type

		if type == "E" then
			type = "error"
		elseif type == "W" then
			type = "warning"
		elseif type == "I" then
			type = "info"
		elseif type == "N" then
			type = "note"
		end

		table.insert(parts, type)
	end

	if item.nr > 0 then
		if item.type == "" then
			table.insert(parts, "error")
		end

		table.insert(parts, tostring(item.nr))
	end

	return table.concat(parts, " ")
end

---@param message string
---@return string
local function format_message(message)
	local m = message:gsub("[%c]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	return m
end

---@return string[]
function M.quickfixtextfunc(info)
	local items = get_items(info)
	---@type string[]
	local formatted_items = {}

	for i = info.start_idx, info.end_idx do
		local parts = {}
		local item = items[i]
		local label = format_label(item)
		local metadata = format_metadata(item)
		local message = format_message(item.text)

		if label ~= "" then
			table.insert(parts, label)
		end

		table.insert(parts, ("|%s|"):format(metadata))

		if message ~= "" then
			table.insert(parts, message)
		end

		table.insert(formatted_items, table.concat(parts, " "))
	end

	return formatted_items
end

return M

local M = {}

-- State tracking
local terminals = {} -- name -> bufnr mapping

-- Helper to get or create a terminal buffer
local function get_or_create_terminal(name, cmd, opts)
	opts = opts or {}
	
	-- Check if terminal exists and is valid
	local bufnr = terminals[name]
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		if opts.replace then
			-- Kill the existing terminal
			vim.api.nvim_buf_delete(bufnr, { force = true })
			terminals[name] = nil
		else
			-- Terminal exists and replace not requested
			return bufnr, false -- buffer, is_new
		end
	end
	
	-- Create new terminal buffer
	local term_cmd = cmd
	if opts.cwd then
		term_cmd = string.format("cd %s && %s", vim.fn.shellescape(opts.cwd), cmd)
	end
	
	-- Create a new buffer
	bufnr = vim.api.nvim_create_buf(false, true)
	
	-- Set up the buffer
	vim.api.nvim_buf_set_name(bufnr, "term://" .. name)
	
	-- Store the buffer
	terminals[name] = bufnr
	
	-- Set up autocmd to clean up when terminal is deleted
	vim.api.nvim_create_autocmd("BufDelete", {
		buffer = bufnr,
		once = true,
		callback = function()
			if terminals[name] == bufnr then
				terminals[name] = nil
			end
		end,
	})
	
	return bufnr, true -- buffer, is_new
end

-- Open or create a terminal
function M.open(opts)
	-- Handle old API for backward compatibility
	if type(opts) == "string" then
		local name = opts
		local bufnr = terminals[name]
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_set_current_buf(bufnr)
			return bufnr
		else
			error(string.format("Terminal '%s' does not exist", name))
		end
	end
	
	-- Extract options
	local name = opts.name or error("Terminal name is required")
	local command = opts.command
	
	-- If no command provided, just navigate to existing terminal
	if not command then
		local bufnr = terminals[name]
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			vim.api.nvim_set_current_buf(bufnr)
			return bufnr
		else
			error(string.format("Terminal '%s' does not exist", name))
		end
	end
	
	-- Convert command table to string if needed
	local cmd_str = type(command) == "table" and table.concat(command, " ") or command
	
	-- Get or create the terminal buffer
	local bufnr, is_new = get_or_create_terminal(name, cmd_str, opts)
	
	-- Handle split option
	if opts.split then
		if opts.split == "bottom" then
			vim.cmd("botright split")
		elseif opts.split == "top" then
			vim.cmd("topleft split")
		elseif opts.split == "right" then
			vim.cmd("botright vsplit")
		elseif opts.split == "left" then
			vim.cmd("topleft vsplit")
		else
			error("Unknown split option: " .. opts.split)
		end
	end
	
	-- Switch to the buffer
	vim.api.nvim_set_current_buf(bufnr)
	
	-- If it's a new terminal, we need to actually start it
	if is_new then
		-- Build the full command
		local term_cmd = cmd_str
		if opts.cwd then
			term_cmd = string.format("cd %s && %s", vim.fn.shellescape(opts.cwd), cmd_str)
		end
		
		-- Start the terminal
		vim.fn.termopen(term_cmd, {
			on_exit = function(job_id, exit_code, event)
				-- Terminal exited, keep buffer for viewing
			end,
		})
		
		-- Go to insert mode if requested (default: stay in normal)
		if opts.insert then
			vim.cmd("startinsert")
		else
			-- Scroll to bottom
			vim.cmd("normal! G")
		end
	end
	
	return bufnr
end

-- List all terminals
function M.list()
	local result = {}
	for name, bufnr in pairs(terminals) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			table.insert(result, name)
		else
			-- Clean up invalid entries
			terminals[name] = nil
		end
	end
	table.sort(result)
	return result
end

-- Kill a specific terminal
function M.kill(name)
	local bufnr = terminals[name]
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true })
		terminals[name] = nil
		return true
	end
	return false
end

-- Kill all terminals
function M.kill_all()
	for name, _ in pairs(terminals) do
		M.kill(name)
	end
end

-- FZF picker for terminals
function M.pick()
	local names = M.list()
	if #names == 0 then
		vim.notify("No terminals found", vim.log.levels.INFO)
		return
	end
	
	-- If only one terminal, just open it
	if #names == 1 then
		M.open(names[1])
		return
	end
	
	-- Use vim.ui.select for now (can be overridden by plugins like telescope)
	vim.ui.select(names, {
		prompt = "Select terminal:",
		format_item = function(name)
			local bufnr = terminals[name]
			if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
				-- Check if terminal is running
				local chan = vim.api.nvim_buf_get_var(bufnr, "terminal_job_id")
				if chan and vim.fn.jobwait({chan}, 0)[1] == -1 then
					return name .. " [running]"
				else
					return name .. " [finished]"
				end
			end
			return name
		end,
	}, function(choice)
		if choice then
			M.open(choice)
		end
	end)
end

-- Get terminal buffer by name
function M.get_bufnr(name)
	local bufnr = terminals[name]
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		return bufnr
	end
	return nil
end

-- Setup function for any initialization
function M.setup(opts)
	opts = opts or {}
	
	-- Could add keymaps, commands, etc. here if needed
end

return M
local M = require'gdb.modules.iface':new()
local log = require'gdb.log'

M.name = 'frame'

function M:on_attach()
end

function M:on_detach()
end


local function parse_stop(str)
	-- thread selected
	local fullpath = str:match('fullname="([^"]+)')
	local line = tonumber(str:match('line="([^"]+)'))
	local thread = tonumber(str:match('thread-id="([^"]+)'))
	log.debug('stopped at file: ', fullpath, 'line=', line)
	M._curr = {
		file = fullpath,
		line = line,
		thread = thread
	}
	M:render()
	return {file = fullpath, line = line}
end

function M:render()
	--  TODO: Module should call generic UI function
	-- named like open_file
	local file = M._curr.file
	local line = M._curr.line or 0
	log.info('opening file', file)
	-- vim.api.nvim_set_current_win()
	if vim.fn.filereadable(file) == 1 then
		vim.api.nvim_command('edit ' .. file)
		vim.api.nvim_win_set_cursor(0, {line, 0})
	end
end

M.parsers = {
	{
		pattern = "stopped",
		pfunc = parse_stop
	}
}

M.callbacks = {
}

return M

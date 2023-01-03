local M = require'gdb.modules.iface':new()
local log = require'gdb.log'

M.name = 'frame'

function M:attach()
	log.debug('attached frames module')
end

function M:detach()
	log.debug('detached frames module')
end

M.parsers = {
}

M.callbacks = {
}

local function parse_stop(str)
	-- thread selected
	local file = str:match('fullname="([^"]+)')
	local line = tonumber(str:match('line="([^"]+)'))
	local thread = tonumber(str:match('thread-id="([^"]+)'))
	log.debug('stopped at file: ', file, 'line=', line)
	M.curr = {
		file = file,
		line = line,
		thread = thread
	}
	return {file = file, line = line}
end

return M

local M = {}

local log = require('gdb.log')
--local mi = require('gdb.mi')

function M.get_stack()
	-- mi.send('-stack-list-frames')
end

function M.parse(str)
	local frames = {}
	for m in str:gmatch('frame=(%b{})') do local level = tonumber(m:match('level="([^"]+)')) + 1
		if not level then return end
		frames[level] = {}
		local frame = frames[level]
		frame.addr = m:match('addr="([^"]+)')
		frame.func = m:match('func="([^"]+)')
		frame.file = m:match('file="([^"]+)')
		frame.full = m:match('fullname="([^"]+)')
		frame.line = tonumber(m:match('line="([^"]+)'))
	end
	M.frames = frames
end

function M.parse_stop(str)
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

-- frame structure is the same as parse_stop
-- it will be nice to follow DRY
function M.select_frame(str)
	local id = str:match('id=""')
end

return M

local M = {}
local api = vim.api
local log = require('gdb.log')

function M.create()
	M.files = {}
end

function M.parse(str)
	if not str then return end
	log.trace('breakpoint event')
	-- Can be created modified and deleted
	local file = str:match('fullname=(%b"")')
	if not file then return end
	file = file:sub(2, -2)
	local line = str:match('line=(%b"")')
	local id = str:match('number=(%b"")')
	local en = str:match('enabled=(%b"")') == '"y"'
	local times = str:match('times=(%b"")')
	line = tonumber(line:sub(2, -2))
	id = tonumber(id:sub(2, -2))
	times = tonumber(times:sub(2, -2))
	log.debug('f: ', file, ', l:', line, 'id:', id, 'e:', en)
	if not M.files[file] then
		M.files[file] = {}
		M.files[file].bps = {}
	end
	-- Note about modified hit in br
	if not M.files[file].bps[id] and id then
		M.files[file].bps[id] = {}
	end
	local bp = M.files[file].bps[id]
	bp.line = line
	bp.en = en
	bp.times = times
	-- Low level module do not need to know ui thing
	--[[ if M.files[file].buf and not bp.sign then
		bp.sign = signs.place_bp(M.files[file].buf, line)
	end ]]
	log.debug('bps', M.files)
end

function M.clean()
	M.files = nil
	log.debug(M.files)
end

return M

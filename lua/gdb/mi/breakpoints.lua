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
	local file = str:match('fullname="([^"]+)')
	if not file then return end
	local line = str:match('line="([^"]+)')
	local id = str:match('number="([^"]+)')
	local en = str:match('enabled="([^"]+)') == 'y'
	local times = str:match('times="([^"]+)')
	line = tonumber(line)
	id = tonumber(id)
	times = tonumber(times)
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
	log.debug('bps updated', M.files)
end

function M.clean()
	M.files = nil
	log.debug(M.files)
end

return M

local M = require('gdb.modules.iface'):new()

local log = require('gdb.log')

M.name = "breakpoints"

function M:on_attach()
	self.files = {}
end

function M:on_detach()
	self.files = nil
	log.debug(self.files)
end


local get_bp_info
local parse
local parse_list

parse = function(str)
	log.trace('breakpoint event')
	-- Can be created modified and deleted
	if str:match('delete') then
		local id = tonumber(str:match('id="([^"]+)'))
		for _,v in ipairs(M.files) do
			if v.bps[id] then
				v.bps[id] = nil
			end
		end
	elseif  str:match('modified') then
	elseif  str:match('created') then
	end
	local file, line = get_bp_info(str)
	return {file = file, line = line}
end

get_bp_info = function(str)
	local file = str:match('fullname="([^"]+)')
	local line = tonumber(str:match('line="([^"]+)'))
	local id = tonumber(str:match('number="([^"]+)'))
	local times = tonumber(str:match('times="([^"]+)'))
	local en = str:match('enabled="([^"]+)') == 'y'
	local cond = str:match('cond="([^"]+)')
	if not file or not id then return end
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
	bp.cond = cond
	log.debug('bps updated', M.files)
	return file, line
end

parse_list = function(str)
	for s in str:gmatch("bkpt=(%b{})") do
		get_bp_info(s)
	end
	log.trace('bps table')
end

M.parsers = {
	{
		pattern = '=breakpoint',
		pfunc = parse
	},
	{
		pattern = '=breakpoint-table',
		pfunc = parse_list
	}
}

return M

local M = {}

local util = require('gdb.utils')
local vars = require('gdb.mi.var')

-- Follow variables tree in depth to get all values
-- str represents list of variable values if is a struct or 
-- just a single value
-- TODO: Proper tail calls if possible

function M.parse(str)
	local locals = {}
	for m in string.gmatch(str, '%b{}') do
		local name = m:match('name=(%b"")'):sub(2, -2)
		local v = m:sub(2, -2):match('value="(.+)"$')
		local var = vars:new(name)
		util.parse_value(v, var)
		table.insert(locals, var)
	end
	M.locals = locals
	return { locals = true }
end

return M

local M = {}

local util = require('gdb.utils')
M.locals = {}

function M.clear_locals()
end

-- Follow variables tree in depth to get all values
-- str represents list of variable values if is a struct or 
-- just a single value
-- TODO: Proper tail calls if possible

function M.parse(str)
	for m in string.gmatch(str, '%b{}') do
		local name = string.match(m, 'name=(%b"")')
		name = string.sub(name, 2, -2)
		local v = string.match(m:sub(2,-2), 'value="(.+)"$')
		M.locals[name] = util.parse_value(v)
	end
end

return M

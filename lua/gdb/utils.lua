local vars = require('gdb.mi.var')

local M = {}

-- Function parsing returned values which can be structure or a scalar
M.parse_value = function(str, parent)
	if not str:match('^%b{}') then
		parent.value = str
		return
	end
	str = str:sub(2,-2)
	local f, cnt, s = 0, 0, 1
	local char, list = _, {}
	while f do -- Splits values of variables by comma
		_, f, char = string.find(str,'([{}()<>,])', f + 1)
		if char == '{' or char == '(' or char == '<' then
			cnt = cnt + 1
		elseif char == '}' or char == ')' or char == '>' then
			cnt = cnt - 1
		elseif char == ',' and cnt == 0 then
			table.insert(list, str:sub(s, f - 1))
			s = f + 2
		end
	end
	table.insert(list, str:sub(s))
	print(vim.inspect(list))
	for _,val in ipairs(list) do
		local name, v = val:match('([^{}]+) = (.+)')
		local child = vars:new(name)
		parent:add_child(child)
		M.parse_value(v, child)
	end
end

return M


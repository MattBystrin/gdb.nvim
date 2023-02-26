local M = {}
-- local send = require('gdb.mi')
-- -data-evaluate-expression
M.expr_list = {}

M.eval = function(list)
	for i,v in ipairs(list) do
		v = v:gsub(' ', '')
		print(i .. '-data-evaluate-expression ' .. v)
	end
end

M.parse = function(str)
	local s = '^done,value="1"'
	print(s)
end

-- M.eval({'kek', 'kok'})

return M

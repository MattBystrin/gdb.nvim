local M = {}

M.parse_tree = function(str)
	local o, c, f = 0, 0, 0
	local s, char = 1, nil
	local tree, list = {}, {}
	while f do
		_, f, char = string.find(str,'([{},])', f + 1)
		if char == '{' then o = o + 1
		elseif char == '}' then c = c + 1
		elseif char == ',' and o == c then
			o, c = 0, 0
			table.insert(list, str:sub(s, f - 1))
			s = f + 2
		end
	end
	table.insert(list, str:sub(s))
	for _,val in ipairs(list) do
		local name, v = val:match('(%w+) = (.+)')
		if not v then return end
		tree[name] = v:find('%b{}') and  M.parse_tree(v:sub(2, -2)) or v
	end
	return tree
end

return M


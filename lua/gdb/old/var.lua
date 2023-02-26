local M = {}

function M:new(name, value)
	name = name or "<Unknown name>"
	local var = { children = {} , name = name, value = value}
	setmetatable(var, self)
	self.__index = self
	return var
end

function M:add_child(child)
	table.insert(self.children, child)
end

function M:expand(ident, t)
	local val = self.value or ""
	table.insert(t, ident .. self.name .. ": " .. val)
	ident = ident .. " "
	for _,i in ipairs(self.children) do
		i:expand(ident, t)
	end
end

--[[ local papa = M:new('papa')
for _,i in ipairs({'son1', 'son2', 'son3'}) do
	local son = M:new(i)
	table.insert(son.children, M:new('grandson'))
	table.insert(papa.children, son)
end

papa:expand("") ]]

return M

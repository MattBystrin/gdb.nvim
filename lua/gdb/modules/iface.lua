local M = {}

local log = require'gdb.log'

M.parsers = {}
M.name = "interface"

function M:attach()
	log.debug('attached ' .. self.name .. ' module')
end

function M:detach()
	log.debug('detached ' .. self.name .. ' module')
end

function M:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

return M

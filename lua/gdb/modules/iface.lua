local M = {}

M.parsers = {
	{
		pattern = "<some lua pattern>",
		handler = function()
			-- Some processing
		end
	}
}

M.name = "abstract"

function M:on_attach()
	-- Actions to be done when module is attached
end

function M:on_detach()
	-- Actions to be done when module is detached
end

function M:on_stop(reason, file, line)
	-- Actions to be done when programm exection stops
	-- i.e. open file where execution stopped
end

function M:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

return M

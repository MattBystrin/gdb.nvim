local M = {}

local parsers = {
	{
		pattern = "<some lua pattern>",
		handler = function()
			-- Some processing
		end
	}
}

local exported = {
	abstract = function()
		vim.api.nvim_echo({ { 'abstract action' } }, false, {})
	end
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

function M:parsers()
	-- Returns table with parsers
	return parsers
end

function M:export()
	-- Returns table with parsers
	return exported
end

function M:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

return M

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
	abstract = function(args)
		vim.api.nvim_echo({ { 'abstract action' } }, false, {})
		vim.api.nvim_echo({ { vim.inspect(args) } }, false, {})
	end
}

local stop_handlers = {
	function(reason, file, line)
		_ = reason
		_ = file
		_ = line
	end
}

M.name = "abstract"

-- Actions to be done when module is attached
function M:on_attach(cfg)
end

-- Actions to be done when module is detached
function M:on_detach()
end

-- Returns table with parsers
function M:parsers()
	return parsers
end

-- Return table with stop handlers
function M:stop_handlers()
	return stop_handlers
end

-- Returns table with parsers
function M:export()
	return exported
end

function M:new(t)
	t = t or {}
	setmetatable(t, self)
	self.__index = self
	return t
end

return M

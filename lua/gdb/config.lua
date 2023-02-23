local M = {}

-- Must be local but for debug reasons it is part of table
local user_config = {}

local default = {
	command = {
		"gdb",
		"--cd",
		"tests/intgr/c",
		"--ex",
		"source gdbinit"
	},
	remote = {
		addr = nil,
		cmd = nil
	},
	modules = {
		"frames"
	},
}

-- Have to be reenterable
function M.setup(config)
	config = config or {}
	-- TODO: Add config validation
	user_config = vim.tbl_deep_extend("keep", config, default);
end

setmetatable(M, {
	__index = function(_,k)
		return user_config[k]
	end
})

return M

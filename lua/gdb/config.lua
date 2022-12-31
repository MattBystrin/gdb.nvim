local M = {}

local user_config = {}

local default = {
	command = "gdb",
	remote = "",
	layout = {
		term_size = 10
	}
}

-- Can be called multiple times
function M.setup(config)
	config = config or {}
	user_config = vim.tbl_deep_extend("keep", config, default);
end

setmetatable(M, {
	__index = function(_, k)
		return user_config[k]
	end
})

return M

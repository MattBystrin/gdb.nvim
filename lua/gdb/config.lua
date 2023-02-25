local M = {}

local user_config = {}

local default = {
	file = nil,
	command = {
		"gdb",
		"--cd",
		"tests/intgr/c",
		"--ex",
		"source gdbinit"
	},
	remote = {
		addr = ":1234",
		cmd = {
			"gdbserver",
			"--multi",
			":1234"
		}
	},
	modules = {
		test = {
			config = "value"
		}
	},
	layout = {
		top = {},
		left = {},
		right = { "terminal" },
		bottom = {}
	},
	ui = {
		linehl = 'StatusLine',
		bp_sign = 'B',
	}
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

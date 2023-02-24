if vim.g.gdbnvim_loaded == 1 then
	return
end
vim.g.gdbnvim_loaded = 1

local gdb = require('gdb')
-- Local names for modules
-- Aliases
local api = vim.api

local stop_debug
-- Stop function
local function start_debug()
	api.nvim_create_user_command('GdbStop', stop_debug, {})
	api.nvim_create_user_command('GdbMI', function(data)
		require('gdb.core').misend(data.args)
	end, {nargs='*'})
	gdb.start_debug()
end

function stop_debug()
	gdb.stop_debug()
	api.nvim_del_user_command('GdbStop')
	api.nvim_del_user_command('GdbMI')
end

api.nvim_create_user_command('GdbStart', start_debug, {nargs='*'})

require'gdb.config'.setup()

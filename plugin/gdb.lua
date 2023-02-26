if vim.g.gdbnvim_loaded == 1 then
	return
end
vim.g.gdbnvim_loaded = 1

local gdb = require('gdb')
local core = require('gdb.core')
local api = vim.api

local debug_stop
-- Stop function
local function debug_start()
	api.nvim_create_user_command('GdbStop', debug_stop, {})
	api.nvim_create_user_command('GdbMI', function(data)
		core.mi_send(data.args)
	end, {nargs='*'})
	gdb.debug_start()
end

function debug_stop()
	gdb.debug_stop()
	api.nvim_del_user_command('GdbStop')
	api.nvim_del_user_command('GdbMI')
end

api.nvim_create_user_command('GdbStart', debug_start, {nargs='*'})

require'gdb.config'.setup()

-- Local names for modules
local log = require'gdb.log'
local term = require'gdb.term'
local mi = require'gdb.mi'
local ui = require'gdb.ui'
-- Aliases
local api = vim.api
-- Stop function
local function stop()
	for _,m in pairs({term, mi, ui}) do
		m.cleanup()
	end
	api.nvim_del_user_command('GDBS')
	api.nvim_del_user_command('GDBM')
	api.nvim_set_var('gdb', false)
	log.info('plugin stpped')
end

local function launch()
	log.info('starting plugin')
	api.nvim_create_user_command('GDBS', stop, {})
	api.nvim_create_user_command('GDBM', function(data)
		mi.send(data.args)
	end, {nargs='*'})
	if vim.g.gdb == true then
		error('already runnig')
	else
		api.nvim_set_var('gdb', true)
	end
	-- Start routine
	local pty = mi.init()
	local tbuf = term.init({
		'gdb', '-ex', 'source tests/c/test_gdb'
	}, pty)
	-- View stuff
	ui.init({term = tbuf})
end
api.nvim_create_user_command('GDBL', launch, {})

-- Entry point at least for development
package.loaded["gdb.mi"] = nil
package.loaded["gdb.mi.stepline"] = nil
package.loaded["gdb.mi.breakpoints"] = nil
package.loaded["gdb.ui"] = nil
package.loaded["gdb.log"] = nil
package.loaded["gdb.term"] = nil
-- Local names for modules
local log = require'gdb.log'
local ui = require'gdb.ui'
local term = require'gdb.term'
local mi = require'gdb.mi'
-- Aliases
local api = vim.api
-- Stop function
local function stop()
	term.stop()
	mi.stop()
	ui.clean()
	api.nvim_del_user_command('GDBS')
	api.nvim_del_user_command('GDBM')
	api.nvim_set_var('gdb', false)
	log.info('plugin stpped')
end
local function start()
	log.info('starting plugin')
	api.nvim_create_user_command('GDBS', stop, {})
	api.nvim_create_user_command('GDBM', mi.write, {nargs='*'})
	if vim.g.gdb == true then
		error('already runnig')
	else
		api.nvim_set_var('gdb', true)
	end
	-- Start routine
	mi.create()
	local tbuf = term.create({
		'gdb', '-ex', 'source tests/c/test_gdb'
	}, mi.get_pty())
	-- View stuff
	ui.create({term = tbuf})
end
api.nvim_create_user_command('GDBL', start, {})


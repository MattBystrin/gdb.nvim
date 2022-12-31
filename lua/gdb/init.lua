local M = {}

local term = require'gdb.term'
local mi = require'gdb.mi'
local ui = require'gdb.ui'
local log = require'gdb.log'

local api = vim.api

function M.start_debug()
	if vim.g.gdb == true then
		error('already runnig')
	else
		api.nvim_set_var('gdb', true)
	end
	-- Start routine
	local pty = mi.init()
	local tbuf = term.init({
		'gdb', '-ex', 'source tests/c/gdbinit'
	}, pty)
	-- View stuff
	ui.init({term = tbuf})
end

function M.stop_debug()
	for _,m in pairs({term, mi, ui}) do
		m.cleanup()
	end
	log.info('debug stopped')
end

function M.setup(config)
	require("gdb.config").setup(config)
end

function M.next()
	vim.api.nvim_echo({{'next'}}, false, {})
end

function M.step()
	vim.api.nvim_echo({{'step'}}, false, {})
end

function M.continue()
	vim.api.nvim_echo({{'continue'}}, false, {})
end

function M.toggle_breakpoint()
	vim.api.nvim_echo({{'toggle bp'}}, false, {})
end

function M.finish()
	vim.api.nvim_echo({{'finish'}}, false, {})
end

return M

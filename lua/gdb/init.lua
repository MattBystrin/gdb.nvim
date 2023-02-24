local M = {}

local log = require 'gdb.log'
local core = require 'gdb.core'
local ui = require 'gdb.ui'

function M.start_debug()
	if vim.g.gdb_run then
		vim.api.nvim_echo({
			{'Debug already running!' , 'ErrorMsg' }
		}, false, {})
		return
	end
	vim.g.gdb_run = true
	log.info('Debug started')
	-- Prepare
	ui.prepare()
	core.register_modules(require'gdb.config'.modules)
	core.start()
	ui.start()
end

function M.stop_debug()
	if not vim.g.gdb_run then
		return
	end
	core.stop()
	core.unregister_modules()
	ui.cleanup()

	vim.g.gdb_run = false
	log.info('debug stopped')
end

function M.setup(config)
	require("gdb.config").setup(config)
end

function M.next()
	vim.api.nvim_echo({ { 'next' } }, false, {})
	core.misend("-exec-next")
end

function M.step()
	vim.api.nvim_echo({ { 'step' } }, false, {})
	--mi.send("-exec-step")
end

function M.continue()
	vim.api.nvim_echo({ { 'continue' } }, false, {})
	--mi.send("-exec-continue")
end

function M.stop()
	vim.api.nvim_echo({ { 'stop execution' } }, false, {})
	--mi.send("-exec-interrupt")
end

function M.bkpt()
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf
	vim.api.nvim_echo({ { 'toggle bp' .. file .. ':' .. line } }, false, {})
end

function M.bkpt_en()
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf
	vim.api.nvim_echo({ { 'bkpt_en in ' .. file .. ':' .. line } }, false, {})
end

function M.exec_until()
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf
	--mi.send("-exec-until " .. file .. ":" .. line)
end

function M.finish()
	vim.api.nvim_echo({ { 'finish' } }, false, {})
	--mi.send("-exec-finish")
end

return M

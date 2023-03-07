local M = {}

local log = require 'gdb.log'
local core = require 'gdb.core'
local ui = require 'gdb.ui'

M.__index = function(_, key)
	if not core.exported[key] then
		return function()
			vim.api.nvim_echo({ { 'Function ' .. key .. '() not exist or not exported' } }, false, {})
		end
	else
		return core.exported[key]
	end
end
setmetatable(M, M)

function M.debug_start()
	if vim.g.gdb_run then
		vim.api.nvim_echo({
			{ 'Debug already running!', 'ErrorMsg' }
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

function M.debug_stop()
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
	-- Maybe set to null some core tables
	require'gdb.config'.setup(config)
end

-- Only basic programm execution commands. Other commands exports via
-- core.export field. But you can call them directly.
function M.next()
	ui.reset_pcline()
	core.mi_send("-exec-next")
end

function M.step()
	ui.reset_pcline()
	core.mi_send("-exec-step")
end

function M.continue()
	ui.reset_pcline()
	core.mi_send("-exec-continue")
end

function M.stop()
	core.mi_send("-exec-interrupt")
end

function M.jump()
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0)
	core.mi_send("-exec-jump " .. file .. ":" .. line)
end

function M.exec_until()
	ui.reset_pcline()
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf
	core.mi_send("-exec-until " .. file .. ":" .. line)
end

function M.finish()
	ui.reset_pcline()
	core.mi_send("-exec-finish")
end

return M

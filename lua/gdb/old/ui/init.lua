--[[
-- Module is resonsible for creating windows. Layout is configured by user. Drawn elements must be added to view.
--]]
local M = {}

local api = vim.api

local log = require'gdb.log'
local signs = require'gdb.ui.signs'
-- local wins = require'gdb.ui.wins'
local locals = require'gdb.ui.locals'

-- Get source file buffer and window
-- Create window for gdb and other stuff

local function open_term(buf)
	api.nvim_command("bo split")
	M.term = api.nvim_get_current_win()
	api.nvim_set_current_buf(buf)
	api.nvim_win_set_height(M.term, 10)
	vim.opt['winfixheight'] = true
end

function M.init(bufs)
	signs.init()
	log.info("creating view", bufs)
	M.src = api.nvim_get_current_win()
	open_term(bufs.term)
	--locals.init()
	api.nvim_set_current_win(M.src) -- Reset view
end

M.notify = vim.schedule_wrap(function(updates)
	if not updates then return end
	log.trace(updates)
	-- if updates.var then
	-- 	locals.update()
	-- end
	if updates.stop then
		local tmp = vim.api.nvim_get_current_win()
		local buf = M.open_file(updates.stop.file, updates.stop.line)
		signs.update_pc(buf, updates.stop.line)
		vim.api.nvim_set_current_win(tmp)
	end
	if updates.bps then
		signs.place_bp(updates.bps.file, updates.bps.line)
	end
	--print(vim.inspect(updates))
end)

function M.open_file(file, line)
	line = line or 0
	if not file then return end
	log.info('opening file', file)
	vim.api.nvim_set_current_win(M.src)
	if vim.fn.filereadable(file) == 1 then
		vim.api.nvim_command('edit ' .. file)
		vim.api.nvim_win_set_cursor(M.src, {line, 0})
	end
	return vim.api.nvim_get_current_buf()
end

function M.cleanup()
	--locals.cleanup()
	signs.cleanup()
	log.info("cleaning view")
	if M.term and api.nvim_win_is_valid(M.term) then
		if #api.nvim_tabpage_list_wins(0) > 1 then
			api.nvim_win_close(M.term, false)
		end
	end
end

--[[ local function update_view(file, line)
	if file and line then
		local tmp = vim.api.nvim_get_current_win()
		M.open_file(file, line)
		local buf = vim.api.nvim_get_current_buf()
		signs.update_pc(buf, line)
		vim.api.nvim_set_current_win(tmp)
	end
end ]]

return M

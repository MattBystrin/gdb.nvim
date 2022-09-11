--[[
-- Module is resonsible for creating windows. Layout is configured by user.
-- Drawn elements must be added to view.
--]]
local M = {}

local api = vim.api
local log = require'gdb.log'

-- Get source file buffer and window
-- Create window for gdb and other stuff
function M.create(bufs)
	log.info("creating view", bufs)
	M.src = api.nvim_get_current_win()
	api.nvim_command("bo split")
	M.term = api.nvim_get_current_win()
	api.nvim_set_current_buf(bufs.term)
	api.nvim_win_set_height(M.term, 10)
	vim.opt['winfixheight'] = true
	api.nvim_set_current_win(M.src) -- Reset view
end

function M.open(app)
end

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

function M.add(app)
end

function M.remove(app)
end

function M.clean()
	log.info("cleaning view")
	if M.term and api.nvim_win_is_valid(M.term) then
		if #api.nvim_tabpage_list_wins(0) > 1 then
			api.nvim_win_close(M.term, false)
		end
	end
end

return M

local M = {}

local api = vim.api
local locals = require('gdb.mi.locals')

M.init = function()
	M.buf = api.nvim_create_buf(true, true)
	api.nvim_buf_set_name(M.buf, 'Locals')
	api.nvim_buf_set_lines(M.buf, -1, -1, 0, {'Local variables'})
	M.create_win()
end

M.create_win = function()
	api.nvim_command("bo vsplit")
	M.win = api.nvim_get_current_win()
	api.nvim_win_set_width(M.win, 45)
	vim.opt['winfixwidth'] = true
	api.nvim_set_current_buf(M.buf)
end

M.open = function()
	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_set_current_win(M.win)
	else
		M.create_win()
	end
end

-- Ui data table stores link to variable data in list and
-- its state and line
-- When ui got updated new elements compared by name and 
-- "inherit" state of "ancestor" with the same name

M.update = function()
	if not locals.locals then return end
	local render = {}
	for _,v in pairs(locals.locals) do
		v:expand(" ", render)
	end
	api.nvim_buf_set_lines(M.buf, 0, -1, true, render)
end

M.cleanup = function()
	if M.win and api.nvim_win_is_valid(M.win) then
		api.nvim_win_close(M.win, false)
	end
	api.nvim_buf_delete(M.buf, {force = true})
end

return M

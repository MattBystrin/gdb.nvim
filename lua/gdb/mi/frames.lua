local M = {}
-- local mi = require('gdb.mi')
-- -stack-list-frames

local log = require('gdb.log')
local ui = require('gdb.ui')
local signs = require('gdb.ui.signs')

function M.get_stack()
	-- mi.send('-stack-list-frames')
end

function M.parse(str)
	local frames = {}
	for m in str:gmatch('frame=(%b{})') do local level = tonumber(m:match('level="([^"]+)')) + 1
		if not level then return end
		frames[level] = {}
		local frame = frames[level]
		frame.addr = m:match('addr="([^"]+)')
		frame.func = m:match('func="([^"]+)')
		frame.file = m:match('file="([^"]+)')
		frame.full = m:match('fullname="([^"]+)')
		frame.line = tonumber(m:match('line="([^"]+)'))
	end
	M.frames = frames
end

function M.parse_stop(str)
	local file = string.match(str, 'fullname="([^"]+)')
	local line = tonumber(string.match(str, 'line="([^"]+)'))
	log.debug('stopped at file: ', file, 'line=', line)
	if file and line then
		local tmp = vim.api.nvim_get_current_win()
		ui.open_file(file, line)
		local buf = vim.api.nvim_get_current_buf()
		signs.update_pc(buf, line)
		vim.api.nvim_set_current_win(tmp)
	end
end

function M.select_frame()
end

return M

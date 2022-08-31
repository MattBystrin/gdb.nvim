local M = {}
local fn = vim.fn
local open_file = require('gdb.ui').open_file
local log = require('gdb.log')

function M.init()
	M.buf = nil
	M.id = nil
	log.debug('init pc')
	fn.sign_define('GDBPC', {
		text = '',
		linehl = 'StatusLine'
	})
end

function M.delete_pc()
	if M.buf and M.id then
		fn.sign_unplace('GDBPC', {
			buffer = M.buf,
			id = M.id
		})
	end
end

function M.update_pc(buf, lnum)
	log.debug('updating pc')
	M.delete_pc()
	M.buf = buf
	M.id = fn.sign_place(0, 'GDBPC', 'GDBPC', buf, {
		lnum = lnum,
		priority = 0
	})
end

function M.parse(data)
	local file = string.match(data, 'fullname="([^"]+)')
	local line = tonumber(string.match(data, 'line="([^"]+)'))
	log.debug('stopped at file: ', file, 'line=', line)
	if file and line then
		local tmp = vim.api.nvim_get_current_win()
		open_file(file, line)
		local buf = vim.api.nvim_get_current_buf()
		M.update_pc(buf, line)
		vim.api.nvim_set_current_win(tmp)
	end
end

function M.cleanup()
	M.buf = nil
	M.id = nil
	fn.sign_unplace('GDBPC')
	fn.sign_undefine('GDBPC')
end

return M

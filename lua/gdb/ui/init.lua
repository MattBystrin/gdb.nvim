local M = {}

local log = require'gdb.log'

function M.start()
	vim.api.nvim_command("bo split")
	M.term = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_height(M.term, 10)
	vim.opt['winfixheight'] = true
	vim.api.nvim_set_current_win(M.source_win)
end

function M.prepare()
	M.source_win = vim.api.nvim_get_current_win()
	log.info('UI prepare. Source win ' .. M.source_win)
	vim.fn.sign_define('GdbPC', { text = '', linehl = 'StatusLine' })
end

function M.cleanup()
	vim.fn.sign_unplace('GdbPC')
	vim.fn.sign_undefine('GdbPC')
end

function M.open_file(file, line)
	line = line or 0
	log.info('opening file', file)
	local oldwin = vim.api.nvim_get_current_win()
	-- vim.api.nvim_set_current_win()
	if vim.fn.filereadable(file) == 1 then
		vim.api.nvim_set_current_win(M.source_win)
		vim.api.nvim_command('edit ' .. file)
		vim.api.nvim_win_set_cursor(0, {line, 0})
	end

	vim.fn.sign_unplace('GdbPC')
	local buf = vim.api.nvim_get_current_buf()
	vim.fn.sign_place(0, 'GdbPC', 'GdbPC', buf, {
		lnum = line,
		priority = 0
	})

	vim.api.nvim_set_current_win(oldwin)
end

return M

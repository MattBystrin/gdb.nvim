local M = {}

local log = require'gdb.log'

function M.start()
	vim.api.nvim_command("bo vsplit")
	M.term = vim.api.nvim_get_current_win()
	local termbuf = require'gdb.core'.get_termbuf()
	vim.api.nvim_set_current_buf(termbuf)
	--vim.api.nvim_win_set_height(M.term, 10)
	vim.opt['winfixheight'] = true
	vim.opt['winfixwidth'] = true
	vim.api.nvim_set_current_win(M.source_win)
end

function M.prepare()
	M.source_win = vim.api.nvim_get_current_win()
	log.info('UI prepare. Source win ' .. M.source_win)
	vim.fn.sign_define('GdbPC', { text = '', linehl = 'SignColumn' })
end

function M.cleanup()
	vim.fn.sign_unplace('GdbPC')
	vim.fn.sign_undefine('GdbPC')
end

function M.open_file(file, line)
	line = line or 0
	if not file then return end

	log.info('opening file ' .. file .. ':' .. line)
	vim.fn.sign_unplace('GdbPC')
	local oldwin = vim.api.nvim_get_current_win()
	-- vim.api.nvim_set_current_win()
	if vim.fn.filereadable(file) == 1 then
		M.open_source_win()
		vim.api.nvim_command('edit ' .. file)
		vim.api.nvim_win_set_cursor(0, {line, 0})
		local buf = vim.api.nvim_get_current_buf()
		vim.fn.sign_place(0, 'GdbPC', 'GdbPC', buf, {
			lnum = line,
			priority = 10
		})
	else
		vim.api.nvim_echo({ { "Failed to open file: " .. file } }, true, {})
	end
	vim.api.nvim_set_current_win(oldwin)
end

-- Opens source win, if was closed, create it
function M.open_source_win()
	if vim.api.nvim_win_is_valid(M.source_win) then
		vim.api.nvim_set_current_win(M.source_win)
	else
		vim.api.nvim_command("to vsplit")
		M.source_win = vim.api.nvim_get_current_win()
	end
end

function M.reset_pcline()
	vim.fn.sign_unplace('GdbPC')
end

return M

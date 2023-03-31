local M = {}

local log = require'gdb.log'
local get_bkpts
local autocmd

local function enter_callback(args)
	local file = vim.fn.fnamemodify(args.file, ':p')
	local buf = args.buf
	log.debug('file acmd:', file, 'buf:', buf)
	local bkpts = get_bkpts() or {}
	for id, bp in pairs(bkpts) do
		if bp.file == file then
			vim.fn.sign_place(id, 'GdbBP', 'GdbBP', buf, {
				lnum = bp.line,
				priority = 0
			})
		end
	end
end

function M.setup(getter)
	get_bkpts = getter
	autocmd = vim.api.nvim_create_autocmd('BufEnter',{
		pattern = {'*.c', '*.h', '*.cpp', '*.hpp', '*.rs'},
		callback = enter_callback
	})
	vim.fn.sign_define('GdbBPe', { text = 'B', texthl = 'WarningMsg' })
	vim.fn.sign_define('GdbBPd', { text = 'D', texthl = 'Normal' })
	vim.fn.sign_define('GdbBPp', { text = 'P', texthl = 'WarningMsg' })
	vim.fn.sign_define('GdbBPc', { text = 'C', texthl = 'WarningMsg' })
end

function M.cleanup()
	vim.fn.sign_undefine('GdbBP')
	vim.api.nvim_clear_autocmds({group = autocmd})
end

function M.sign_set(bkpt)
	local bufs = vim.fn.getbufinfo({buflisted = true})
	for _, buf in ipairs(bufs) do
		if buf.name == bkpt.file then
			vim.fn.sign_place(bkpt.id, 'GdbBP', 'GdbBP', buf.bufnr, {
				lnum = bkpt.line,
				priority = 0
			})
			-- vim.api.nvim_win_set_cursor(ui.source_win, {line, 0})
		end
	end
end

function M.sign_unset(bkpt)
	vim.fn.sign_unplace('GdbBP', { id = bkpt.id })
end


return M

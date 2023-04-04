local M = {}

local log = require'gdb.log'
local ui = require'gdb.ui'
local get_bkpts
local autocmd

local function enter_callback(args)
	local file = vim.fn.fnamemodify(args.file, ':p')
	local buf = args.buf
	log.debug('file acmd:', file, 'buf:', buf)
	local bkpts = get_bkpts() or {}
	for id, bp in pairs(bkpts) do
		if bp.file == file then
			M.sign_set(bp, id)
		end
	end
end

function M.setup(getter)
	get_bkpts = getter
	autocmd = vim.api.nvim_create_autocmd('BufEnter',{
		pattern = {'*.s', '*.S', '*.c', '*.h', '*.cpp', '*.hpp', '*.rs'},
		callback = enter_callback
	})
	vim.fn.sign_define('GdbBP', { text = 'B', texthl = 'WarningMsg' })
	vim.fn.sign_define('GdbBPe', { text = 'B', texthl = 'Normal' })
	vim.fn.sign_define('GdbDP', { text = 'D', texthl = 'WarningMsg' })
	vim.fn.sign_define('GdbDPe', { text = 'D', texthl = 'Normal' })
end

function M.cleanup()
	vim.fn.sign_undefine('GdbBP')
	vim.fn.sign_undefine('GdbBPe')
	vim.fn.sign_undefine('GdbDP')
	vim.fn.sign_undefine('GdbDPe')
	vim.api.nvim_clear_autocmds({group = autocmd})
end

function M.sign_set(bkpt, id)
	local bufs = vim.fn.getbufinfo({buflisted = true})
	for _, buf in ipairs(bufs) do
		local group = M._get_group(bkpt)
		if buf.name == bkpt.file then
			vim.fn.sign_place(id, group, group, buf.bufnr, {
				lnum = bkpt.line,
				priority = 0
			})
			vim.api.nvim_win_set_cursor(ui.source_win, {bkpt.line, 0})
		end
	end
end

function M.sign_update(bkpt, id)
	M.sign_unset(bkpt, id)
	M.sign_set(bkpt, id)
end

function M.sign_unset(bkpt, id)
	local group = M._get_group(bkpt)
	vim.fn.sign_unplace(group, { id = id })
end

function M._get_group(bkpt)
	local group = 'GdbBP'
	if bkpt.type == 'dprintf' then
		group = 'GdbDP'
	end
	if not bkpt.en then
		group = group .. 'e'
	end
	return group
end

return M

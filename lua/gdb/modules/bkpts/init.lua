local M = require('gdb.modules.iface'):new()

local core = require('gdb.core')
local log = require('gdb.log')

M.name = "breakpoints"

local deafult_cfg = {
	texthl = 'WarningMsg',
	text = 'B'
}

--[[
	bps have default, indexed by num
	files have bp indexes contained in file 
--]]

local function enter_callback(args)
	local file = vim.fn.fnamemodify(args.file, ':p')
	local buf = args.buf
	log.debug('file acmd:', file, 'buf:', buf)
	for id, bp in pairs(M.bps) do
		if bp.file == file then
			vim.fn.sign_place(id, 'GdbBP', 'GdbBP', buf, {
				lnum = bp.line,
				priority = 0
			})
		end
	end
end

function M:on_attach(cfg)
	cfg = cfg or {}
	vim.tbl_deep_extend('keep', deafult_cfg, cfg)

	M._cmd_enter = vim.api.nvim_create_autocmd('BufEnter',{
		pattern = {'*.c', '*.h', '*.cpp', '*.hpp', '*.rs'},
		callback = enter_callback
	})

	vim.fn.sign_define('GdbBP', { text = 'B', texthl = 'WarningMsg' })
	M.bps = {}
end

function M:on_detach()
	vim.fn.sign_undefine('GdbBP')
	M.bps = nil
end

local function parse_bp_msg(str)
	local file = str:match('fullname="([^"]+)')
	local line = tonumber(str:match('line="([^"]+)'))
	local id = tonumber(str:match('number="([^"]+)'))
	local hits = tonumber(str:match('times="([^"]+)'))
	local en = str:match('enabled="([^"]+)') == 'y'
	local cond = str:match('cond="([^"]+)')
	local addr = str:match('addr="([^"]+)')

	if not id then return end

	M.bps[id] = M.bps[id] or {}
	M.bps[id].file = file
	M.bps[id].line = line
	M.bps[id].en = en
	M.bps[id].hits = hits
	M.bps[id].cond = cond
	M.bps[id].addr = addr

	return file, line, id
end

local function parse(str)
	log.trace('breakpoint event')
	local file, line, id = parse_bp_msg(str)

	local bufs = vim.fn.getbufinfo({buflisted = true})
	for _, buf in ipairs(bufs) do
		if buf.name == file then
			vim.fn.sign_place(id, 'GdbBP', 'GdbBP', buf.bufnr, {
				lnum = line,
				priority = 0
			})
			-- vim.api.nvim_win_set_cursor(ui.source_win, {line, 0})
		end
	end
end

local function delete_handler(str)
	local id = tonumber(str:match('id="([^"]+)'))
	if not id then return end
	vim.fn.sign_unplace('GdbBP', { id = id })
	M.bps[id] = nil
end


local function parse_list(str)
	for s in str:gmatch("bkpt=(%b{})") do
		parse_bp_msg(s)
	end
end

-- '=breakpoint-created,bkpt={...}'
-- '=breakpoint-modified,bkpt={...}'
-- '=breakpoint-deleted,id=NUMBER'
-- '^done,bkpt={}'
-- '^done,BreakpointTable'

function M.parsers()
	return {
	{ pattern = '^=breakpoint%-created', handler = parse },
	{ pattern = '^=breakpoint%-modified', handler = parse },
	{ pattern = '^=breakpoint%-deleted', handler = delete_handler },
	{ pattern = '^%^done,bkpt=', handler = parse},
	{ pattern = '^%^done,BreakpointTable', handler = parse_list} }
end


local function bkpt(opt)
	opt = opt or {}
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf

	log.debug(M.bps)

	for id, bp in pairs(M.bps) do
		log.debug(bp.file == file and bp.line == line)
		if bp.file == file and bp.line == line then
			M.bps[id] = nil
			core.mi_send("-break-delete " .. id)
			vim.fn.sign_unplace('GdbBP', { id = id })
			return
		end
	end

	core.mi_send("-break-insert " .. file .. ":" .. line)
end

function M.export()
	return {
		bkpt = bkpt
	}
end

return M

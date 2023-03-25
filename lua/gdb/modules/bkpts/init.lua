local M = require('gdb.modules.iface'):new()

local core = require('gdb.core')
local log = require('gdb.log')

M.name = "breakpoints"

--[[
	bps have default, indexed by num
	files have bp indexes contained in file 
--]]

function M:on_attach()
	vim.fn.sign_define('GdbBP', { text = 'B', texthl = 'WarningMsg' })
	self.bps = {}
end

function M:on_detach()
	vim.fn.sign_undefine('GdbBP')
	self.bps = nil
end

local function get_bp_info(str)
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
	local file, line, id = get_bp_info(str)

	local buf = vim.api.nvim_get_current_buf()

	vim.fn.sign_place(id, 'GdbBP', 'GdbBP', buf, {
		lnum = line,
		priority = 0
	})
end

local function delete_handler(str)
	local id = tonumber(str:match('id="([^"]+)'))
	if not id then return end

	M.bps[id] = nil
end


local function parse_list(str)
	for s in str:gmatch("bkpt=(%b{})") do
		get_bp_info(s)
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

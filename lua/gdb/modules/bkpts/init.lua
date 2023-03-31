local M = require('gdb.modules.iface'):new()
M.name = "breakpoints"

local core = require('gdb.core')
local log = require('gdb.log')

local mi = require('gdb.modules.bkpts.mi')
local ui = require('gdb.modules.bkpts.ui')

local deafult_cfg = {
	texthl = 'WarningMsg',
	text = 'B'
}

local function getter()
	return M.bps
end

function M:on_attach(cfg)
	cfg = cfg or {}
	vim.tbl_deep_extend('keep', deafult_cfg, cfg)

	ui.setup(getter)
	M.bps = {}
end

function M:on_detach()
	ui.cleanup()
	M.bps = nil
end

local function modify_handler(str)
	local bkpt = mi.parse_internal(str, M.bps)
	ui.sign_set(bkpt)
end

local function delete_handler(str)
	local id = tonumber(str:match('id="([^"]+)'))
	if not id then return end
	ui.sign_unset(M.bps[id])
	M.bps[id] = nil
end

local function list_handler(str)
	for s in str:gmatch("bkpt=(%b{})") do
		mi.parse_internal(s, M.bps)
	end
end

local function bkpt(opt)
	opt = opt or {}
	local line = opt.line or unpack(vim.api.nvim_win_get_cursor(0))
	local file = opt.file or vim.api.nvim_buf_get_name(0) -- Current buf

	log.debug(M.bps)

	for id, bp in pairs(M.bps) do
		if bp.file == file and bp.line == line then
			M.bps[id] = nil
			core.mi_send("-break-delete " .. id)
			vim.fn.sign_unplace('GdbBP', { id = id })
			return
		end
	end

	core.mi_send("-break-insert " .. file .. ":" .. line)
end

local function bkpt_en(opt)
	opt = opt or {}
	local line = opt.line or unpack(vim.api.nvim_win_get_cursor(0))
	local file = opt.file or vim.api.nvim_buf_get_name(0) -- Current buf

	for id, bp in pairs(M.bps) do
		if bp.file == file and bp.line == line then
			if bp.en then
				core.mi_send("-break-enable " .. id)
			else
				core.mi_send("-break-disable " .. id)
			end
			return
		end
	end
end

local function dprintf(opt)
	opt = opt or {}
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf
	local cond = vim.fn.input('dprintf() format : ')
	if cond == "" then return end
	-- read about command completion
	core.mi_send('-dprintf-insert ' .. file .. ':' .. line .. ' ' .. cond)
end

function M:parsers()
	return {
	{ pattern = '^=breakpoint%-created', handler = modify_handler },
	{ pattern = '^=breakpoint%-modified', handler = modify_handler },
	{ pattern = '^=breakpoint%-deleted', handler = delete_handler },
	{ pattern = '^%^done,bkpt=', handler = modify_handler },
	{ pattern = '^%^done,BreakpointTable', handler = list_handler } }
end

function M:export()
	return {
		bkpt = bkpt,
		bkpt_en = bkpt_en,
		printf = dprintf
	}
end

return M

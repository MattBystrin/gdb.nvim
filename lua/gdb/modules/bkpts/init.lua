local M = require('gdb.modules.iface'):new()
M.name = "breakpoints"
M.bkpts = {}

local core = require('gdb.core')
local log = require('gdb.log')

local mi = require('gdb.modules.bkpts.mi')
local ui = require('gdb.modules.bkpts.ui')

local deafult_cfg = {
	texthl = 'WarningMsg',
	text = 'B'
}

local function getter()
	return M.bkpts
end

function M:on_attach(cfg)
	cfg = cfg or {}
	vim.tbl_deep_extend('keep', deafult_cfg, cfg)

	ui.setup(getter)
end

function M:on_detach()
	ui.cleanup()
	M.bkpts = {}
end

local function modify_handler(str)
	log.debug("Breakpoint modified", M.bkpts)
	local bkpt, id = mi.parse_internal(str, M.bkpts)
	ui.sign_set(bkpt, id)
end

local function delete_handler(str)
	local id = tonumber(str:match('id="([^"]+)'))
	if not id then return end
	ui.sign_unset(M.bkpts[id], id)
	M.bkpts[id] = nil
end

local function list_handler(str)
	for s in str:gmatch("bkpt=(%b{})") do
		mi.parse_internal(s, M.bkpts)
	end
end

local function bkpt(opt)
	opt = opt or {}
	local line = opt.line or unpack(vim.api.nvim_win_get_cursor(0))
	local file = opt.file or vim.api.nvim_buf_get_name(0) -- Current buf

	log.debug(M.bkpts)

	for id, bp in pairs(M.bkpts) do
		if bp.file == file and bp.line == line then
			M.bkpts[id] = nil
			core.mi_send("-break-delete " .. id)
			ui.sign_unset(bp, id)
			return
		end
	end

	core.mi_send("-break-insert " .. file .. ":" .. line)
end

local function bkpt_en(opt)
	opt = opt or {}
	local line = opt.line or unpack(vim.api.nvim_win_get_cursor(0))
	local file = opt.file or vim.api.nvim_buf_get_name(0) -- Current buf

	for id, bkpt in pairs(M.bkpts) do
		if bkpt.file == file and bkpt.line == line then
			if bkpt.en then
				core.mi_send("-break-disable " .. id)
				ui.sign_unset(bkpt, id)
				bkpt.en = false
			else
				core.mi_send("-break-enable " .. id)
				ui.sign_unset(bkpt, id)
				bkpt.en = true
			end
			ui.sign_set(bkpt, id)
			return
		end
	end
end

local function dprintf(opt)
	opt = opt or {}
	local cond = opt.cond or vim.fn.input('dprintf() format : ')
	local line = unpack(vim.api.nvim_win_get_cursor(0))
	local file = vim.api.nvim_buf_get_name(0) -- Current buf
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

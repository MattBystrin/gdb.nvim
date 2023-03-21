local M = require('gdb.modules.iface'):new()

local log = require('gdb.log')

M.name = "breakpoints"
M.files = {}

function M:on_attach()
	M.files = {}
end

function M:on_detach()
	M.files = nil
end

local parse
local parse_list
local delete_handler

-- '=breakpoint-created,bkpt={...}'
--  '=breakpoint-modified,bkpt={...}'
--  '=breakpoint-deleted,id=NUMBER'
--

function M.parsers()
	return {
		{ pattern = '^=breakpoint%-created', handler = parse },
		{ pattern = '^=breakpoint%-modified', handler = parse },
		{ pattern = '^=breakpoint%-deleted', handler = delete_handler },
		{ pattern = '^%^done,BreakpointTable', handler = parse_list}
	}
end

local function get_bp_info(str)
	local file = str:match('fullname="([^"]+)')
	local line = tonumber(str:match('line="([^"]+)'))
	local id = tonumber(str:match('number="([^"]+)'))
	local hits = tonumber(str:match('times="([^"]+)'))
	local en = str:match('enabled="([^"]+)') == 'y'
	local cond = str:match('cond="([^"]+)')
	if not file or not id then return end
	log.debug('f: ', file, ', l:', line, 'id:', id, 'e:', en)
	if not M.files[file] then
		M.files[file] = {}
		M.files[file].bps = {}
	end
	-- Note about modified hit in br
	if not M.files[file].bps[id] and id then
		M.files[file].bps[id] = {}
	end
	local bp = M.files[file].bps[id]
	bp.line = line
	bp.en = en
	bp.hits = hits
	bp.cond = cond
	log.debug('bps updated', M.files)
	return file, line
end

parse = function(str)
	log.trace('breakpoint event')
	-- Can be created modified and deleted
	local file, line = get_bp_info(str)
	return {file = file, line = line}
end

delete_handler = function(str)
	local id = tonumber(str:match('id="([^"]+)'))
	if not id then return end

	for _,v in ipairs(M.files) do
		if v.bps[id] then
			v.bps[id] = nil
		end
	end
end


parse_list = function(str)
	for s in str:gmatch("bkpt=(%b{})") do
		get_bp_info(s)
	end
end


-- Add/delete breakpoint
local function bkpt()
	-- local line = unpack(vim.api.nvim_win_get_cursor(0))
	-- local file = vim.api.nvim_buf_get_name(0) -- Current buf
	-- vim.api.nvim_echo({ { 'toggle bp' .. file .. ':' .. line } }, false, {})
	vim.api.nvim_echo({ { 'not implemented yet' } }, false, {})
end

-- Enable/diasble breakpoint
local function bkpt_en()
	-- local line = unpack(vim.api.nvim_win_get_cursor(0))
	-- local file = vim.api.nvim_buf_get_name(0) -- Current buf
	--vim.api.nvim_echo({ { 'bkpt_en in ' .. file .. ':' .. line } }, false, {})
	vim.api.nvim_echo({ { 'not implemented yet' } }, false, {})
end

return M

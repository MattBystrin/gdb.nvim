local M = {}

local log = require 'gdb.log'

local api = vim.api

function M.mi_send(data)
	api.nvim_chan_send(M.mchan, data .. '\n')
end

local modstable = {}
local parsers = {}
local stop_handlers = {}

function M.register_modules(modlist)
	for name, cfg in pairs(modlist) do
		local res, mod = pcall(require, 'gdb.modules.' .. name)
		if not res then
			log.debug('failed to load module ' .. name)
		else
			-- Attach module
			table.insert(modstable, mod)
			log.debug('attached module: ' .. mod.name)
			mod:on_attach(cfg)
			-- Register parsers
			if mod.parsers then
				for _,p in ipairs(mod.parsers) do
					table.insert(parsers, p)
				end
			end
			-- Register on_stop handle
			if mod.on_stop then
				table.insert(stop_handlers, mod.on_stop)
			end
		end
	end
end

function M.unregister_modules()
	for _, mod in ipairs(modstable) do
		mod:on_detach()
		log.debug('detached module: ' .. mod.name)
		mod = nil
	end
	parsers = {}
	modstable = {}
	stop_handlers = {}
end

local function default_stop_handler(reason, file, line)
	local ui = require'gdb.ui'
	ui.open_file(file, line)
end

local function default_error_handler(msg)
	vim.api.nvim_echo({ { msg } }, true, {})
end

local function mi_parse(str)
	log.debug("data in parse: ", str)
	--  TODO: thread select
	if str:find('^*stopped') then
		local reason = str:match('reason="([^"]+)')
		local file = str:match('fullname="([^"]+)')
		local line = tonumber(str:match('line="([^"]+)'))
		default_stop_handler(reason, file, line)
		for _, handler in ipairs(stop_handlers) do
			handler(str)
		end

		return
	end
	if str:find('^%^error') then
		local msg = str:match('msg="([^"]+)')
		default_error_handler(msg)
		return
	end
	for _, p in ipairs(parsers) do
		if str:find(p.pattern) then
			p.pfunc(str)
		end
	end
end

local midata = ""
function M.mi_on_stdout(_, data) -- Exported for tests
	if not data then return end
	log.debug("data in callback", data)
	-- Here 'raw' data have to be assmebled to analyse it line by line
	for _,v in ipairs(data) do
		if v:find("\r") then
			mi_parse(midata .. v:gsub("\r",""))
			midata = ""
		else
			midata = midata .. v
		end
	end
end

local base_args = {
	"-q",
	"-iex", "set pagination off",
	"-iex", "set mi-async on",
	"-iex", "set breakpoint pending on",
	"-iex", "set print pretty"
}

local function mi_launch()
	log.debug('creating mi job')
	M.mchan = vim.fn.jobstart("tail -f /dev/null #mijob", {
		pty = true,
		on_exit = function()
		end,
		on_stdout = M.mi_on_stdout
	})
	log.debug("mi chan: ", M.mchan)
	if not M.mchan then return nil end
	return vim.api.nvim_get_chan_info(M.mchan)['pty']
end

local function term_launch(command)
	local tmp = api.nvim_get_current_buf() -- Save buffer
	M.tbuf = api.nvim_create_buf(true, false)
	api.nvim_set_current_buf(M.tbuf)
	M.tchan = vim.fn.termopen(command, {
		on_exit = function(_, code)
			log.debug('term exiting: code ' .. code)
			pcall(api.nvim_buf_delete, M.tbuf, { force = true })
		end
	})
	api.nvim_set_current_buf(tmp) -- Restore buffer
	log.debug("gdb buf: ", M.tbuf, ", chan: ", M.tchan)
end

function M.get_termbuf()
	return M.tbuf
end

function M.start(command)
	log.debug("starting core")
	-- Creating pty for MI
	local pty = mi_launch()
	command = require'gdb.config'.command
	for _, v in ipairs(base_args) do
		table.insert(command, v)
	end
	table.insert(command, "-iex")
	table.insert(command, "new-ui mi " .. pty)
	-- Launch terminal
	term_launch(command)
end

function M.stop()
	vim.fn.jobstop(M.mchan)
	vim.fn.jobstop(M.tchan)
end

return M
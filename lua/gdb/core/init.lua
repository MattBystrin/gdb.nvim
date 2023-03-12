local M = {}
M.exported = {}

local log = require 'gdb.log'
local mi = require 'gdb.core.mi'
local api = vim.api

function M.mi_send(data)
	api.nvim_chan_send(mi.mchan, data .. '\n')
end

local modstable = {}
local exported = M.exported
local stop_handlers = mi.stop_handlers
local parsers = mi.parsers

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
			for _,p in ipairs(mod:parsers()) do
				table.insert(parsers, p)
			end
			-- Register on_stop handle
			table.insert(stop_handlers, mod.on_stop)
			-- Export functions to user
			for k,f in pairs(mod:export()) do
				exported[k] = f
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
	exported = {}
	modstable = {}
	mi.cleanup()
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

local base_args = {
	"-q",
	"-iex", "set pagination off",
	"-iex", "set mi-async on",
	"-iex", "set breakpoint pending on",
	"-iex", "set print pretty"
}

local function remote_launch(command)
	if not command then return nil end
	log.debug('creating remote job')
	local remote_chan = vim.fn.jobstart('gdbserver --multi :1234', {
		on_stdout = function(_, data)
			log.debug(data)
		end,
		on_stderr = function(_, data)
			log.debug(data)
		end,
		on_exit = function()
			log.debug("Remote exit")
		end
	})
	log.debug("Remote chan " .. remote_chan)
	if remote_chan <= 0 then
		log.debug("Failed to start remote")
	end
	return remote_chan
end

local r_chan
function M.start(command, remote)
	log.debug("starting core")
	-- Creating remote
	r_chan = remote_launch(remote.cmd)
	-- Creating pty for MI
	local pty = mi.launch()
	local cmd = {}
	for _, v in ipairs(command) do
		table.insert(cmd, v)
	end
	for _, v in ipairs(base_args) do
		table.insert(cmd, v)
	end
	table.insert(cmd, "-iex")
	table.insert(cmd, "new-ui mi " .. pty)
	if remote.addr then
		local rmt = remote.extended and "extended-remote" or "remote"
		table.insert(cmd, "-ex")
		table.insert(cmd, "target " .. rmt .. " " .. remote.addr)
	end
	-- Launch terminal
	term_launch(cmd)
end

function M.stop()
	pcall(vim.fn.jobstop, mi.get_pty())
	pcall(vim.fn.jobstop, r_chan)
	pcall(vim.fn.jobstop, M.tchan)
end

return M

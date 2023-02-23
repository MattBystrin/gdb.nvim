local M = {}

local log = require 'gdb.log'

local api = vim.api

function M.misend(data)
	api.nvim_chan_send(data .. '\n')
end

local modstable = {}
local parsers = {}
function M.register_modules(modlist)
	for _, m in ipairs(modlist) do
		local res, mod = pcall(require, 'gdb.modules.' .. m)
		if not res then
			log.warning('failed to load module ' .. m)
		else
			table.insert(modstable, mod)
			-- Register parsers
			if mod.parsers then
				for _,p in ipairs(mod.parsers) do
					table.insert(parsers, p)
				end
			end
			-- Attach module
			mod:on_attach()
			log.debug('attached module: ' .. mod.name)
		end
	end
end

function M.unregister_modules()
	for _, mod in ipairs(modstable) do
		mod:on_detach()
		log.debug('detached module: ' .. mod.name)
		mod = nil
	end
	parsers = nil
end

local function micore_parse(str)
	log.debug("data in parse: ", str)
	if str:find("stopped") then

	end
	for _,p in ipairs(parsers) do
		if str:find(p.pattern) then
			p.pfunc(str)
		end
	end
end

local midata = ""
function M.mi_on_stdout(_, data) -- Exported for tests
	if not data then return end
	log.debug("data in callback", data)
	-- Here data have to be assmebled to analyse it line by line
	for _,v in ipairs(data) do
		if v:find("\r") then
			micore_parse(midata .. v:gsub("\r",""))
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
	"-iex", "set breakpoint pending on"
}

local function launch_mi()
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

local function launch_term(command)
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

function M.start(command)
	log.debug("starting core")
	-- Creating pty for MI
	local pty = launch_mi()
	command = require'gdb.config'.command
	for _, v in ipairs(base_args) do
		table.insert(command, v)
	end
	table.insert(command, "-iex")
	table.insert(command, "new-ui mi " .. pty)
	-- Launch terminal
	launch_term(command)
end

function M.stop()
	vim.fn.jobstop(M.mchan)
	vim.fn.jobstop(M.tchan)
end


return M
